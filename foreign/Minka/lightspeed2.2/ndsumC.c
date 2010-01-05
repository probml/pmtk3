/* mex ndsumC.c flops.obj
 */
/* Written by Tom Minka
 * (c) Microsoft Corporation. All rights reserved.
 */
#include "mex.h"
#include "flops.h"

void ndsum(double *dest, double *src, unsigned ndim, unsigned *size,
	   unsigned total, unsigned *mask) 
{
  /* dest is the destination array.
   * src is the source array.
   * ndim is the number of dimensions in the source array (the length of size).
   * size[i] is the size of dimension i in the source array.
   * mask[i] indicates that dimension i is to be summed out.
   */
  unsigned *masked_size,*cum_masked_size,*advance,*rewind;
  int *subs = mxCalloc(ndim,sizeof(int));
  int i,j;
  masked_size = mxCalloc(ndim,sizeof(int));
  for(i=0;i<ndim;i++) {
    masked_size[i] = mask[i] ? 1 : size[i];
  }
  /* subs (initialized to zero) is the current position in the source array.
   * cum_masked_size[i] is the cumulative product of masked sizes up to i.
   * rewind[i] is cum_masked_size[i]*(masked_size[i]-1)
   *
   * The position in the destination array is 
   *   sum_i subs[i]*cum_masked_size[i]*!mask[i].
   * To compute this incrementally, we add cum_masked_size[i]*!mask[i] 
   * whenever we increment subs[i], and we subtract rewind[i]
   * whenever we set subs[i] back to 0 (from size[i]-1).
   */
  cum_masked_size = mxCalloc(ndim,sizeof(int));
  advance = mxCalloc(ndim,sizeof(int));
  rewind = mxCalloc(ndim,sizeof(int));
  cum_masked_size[0] = 1;
  for(i=0;i<ndim-1;i++) {
    cum_masked_size[i+1] = cum_masked_size[i]*masked_size[i];
  }
  for(i=0;i<ndim;i++) {
    advance[i] = cum_masked_size[i]*!mask[i];
    rewind[i] = cum_masked_size[i]*(masked_size[i]-1);
  }

  for(j=0;j<total;j++) {
    *dest += *src++;
    /* increment subs and update dest */
    for(i=0;i<ndim;i++) {
      if(subs[i] == size[i]-1) {
	subs[i] = 0;
	dest -= rewind[i];
      }
      else {
	subs[i]++;
	dest += advance[i];
	break;
      }
    }
  }
  mxFree(rewind);
  mxFree(advance);
  mxFree(cum_masked_size);
  mxFree(masked_size);
  mxFree(subs);
}

void mexFunction(int nlhs, mxArray *plhs[], 
		 int nrhs, const mxArray *prhs[])
{
  /* prhs[0] is the multidimensional array.
   * prhs[1] is a vector listing the dimensions to sum out.
   */
  int i,j;
  int ndim = mxGetNumberOfDimensions(prhs[0]);
  const int *size = mxGetDimensions(prhs[0]);
  double *src = mxGetPr(prhs[0]), *dest;
  double *dim = mxGetPr(prhs[1]);
  int nremove = mxGetNumberOfElements(prhs[1]);
  int dest_ndim = ndim - nremove;
  unsigned *dest_size;
  unsigned *mask;
  int total = mxGetNumberOfElements(prhs[0]), dest_total;

  if(dest_ndim == 0) {
    /* sum out everything */
    plhs[0] = mxCreateDoubleMatrix(1,1,mxREAL);
    dest = mxGetPr(plhs[0]);
    for(i=0;i<total;i++) {
      *dest += src[i];
    }
    addflops(total-1);
    return;
  }

  /* convert dim to a mask. */
  /* mask[i] = 1 if dimension i is to be removed. */
  mask = mxCalloc(ndim,sizeof(int));
  /* dimensions in dim are indexed starting from 1. */
  for(i=0;i<nremove;i++) mask[(int)dim[i]-1] = 1;
  /* compute the new size vector. */
  dest_size = mxCalloc(dest_ndim,sizeof(int));
  j = 0;
  for(i=0;i<ndim;i++) {
    if(!mask[i]) dest_size[j++] = size[i];
  }
  plhs[0] = mxCreateNumericArray(dest_ndim, dest_size, mxDOUBLE_CLASS, mxREAL);
  dest_total = mxGetNumberOfElements(plhs[0]);
  dest = mxGetPr(plhs[0]);
  addflops(total-dest_total);
  if(dest_total == total) {
    /* don't sum anything */
    memcpy(dest,src,total*sizeof(double));
    return;
  }
  ndsum(dest,src,ndim,size,total,mask);
}
