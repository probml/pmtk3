/* Written by Tom Minka
 * (c) Microsoft Corporation. All rights reserved.
 */
#include "mex.h"
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int ndims, len, i;
  int *dims;
  double *indata, *outdata;
  long ix,iy,iz;

  if((nlhs > 1) || (nrhs > 1))
    mexErrMsgTxt("Usage: seed = randomseed; (or) randomseed(new_seed);");

  if(nrhs > 0) {
    /* prhs[0] is first argument.
     * mxGetPr returns double*  (data, col-major)
     */
    ndims = mxGetNumberOfDimensions(prhs[0]);
    dims = (int*)mxGetDimensions(prhs[0]);
    indata = mxGetPr(prhs[0]);
    len = mxGetNumberOfElements(prhs[0]);

    if(mxIsSparse(prhs[0]))
      mexErrMsgTxt("Cannot handle sparse matrices.  Sorry.");

    if(len == 1 && *indata == 0.0) {
      ResetSeed();
    } else if(len != 3) {
      mexErrMsgTxt("seed must be 0 or a vector of 3 numbers.");
    } else {
      SetSeed((long)indata[0],(long)indata[1],(long)indata[2]);
    }
  }
  ndims = 1;
  dims = (int*)mxMalloc(sizeof(int));
  dims[0] = 3;
  /* plhs[0] is first output */
  plhs[0] = mxCreateNumericArray(ndims, dims, mxDOUBLE_CLASS, mxREAL);
  outdata = mxGetPr(plhs[0]);
  GetSeed(&ix,&iy,&iz);
  outdata[0] = (double)ix;
  outdata[1] = (double)iy;
  outdata[2] = (double)iz;  
}
  
