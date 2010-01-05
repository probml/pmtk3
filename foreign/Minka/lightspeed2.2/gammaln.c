/* compile with: mex gammaln.c mexutil.c util.c -lm
 * test in matlab:
 *   gammaln(1:10)
 */
/* Written by Tom Minka
 * (c) Microsoft Corporation. All rights reserved.
 */
#include "mex.h"
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int ndims, len, i, nnz;
  int *dims;
  double *indata, *outdata, d;

  if((nlhs > 1) || (nrhs < 1) || (nrhs > 2))    
    mexErrMsgTxt("Usage: x = gammaln(n) or gammaln(n,d)");

  /* prhs[0] is first argument.
   * mxGetPr returns double*  (data, col-major)
   */
  ndims = mxGetNumberOfDimensions(prhs[0]);
  dims = (int*)mxGetDimensions(prhs[0]);
  indata = mxGetPr(prhs[0]);
  len = mxGetNumberOfElements(prhs[0]);

  if(mxIsSparse(prhs[0])) {
    plhs[0] = mxDuplicateArray(prhs[0]);
    /* number of nonzero entries */
    nnz = mxGetJc(prhs[0])[mxGetN(prhs[0])];
    if(nnz != mxGetNumberOfElements(prhs[0])) {
      mexErrMsgTxt("Cannot handle sparse n.");
    }
  } else {
    /* plhs[0] is first output */
    plhs[0] = mxCreateNumericArray(ndims, dims, mxDOUBLE_CLASS, mxREAL);
  }
  outdata = mxGetPr(plhs[0]);

  /* compute gammaln of every element */
  if(nrhs == 1) {
    for(i=0;i<len;i++)
      *outdata++ = gammaln(*indata++);
  } else {
    if(mxGetNumberOfElements(prhs[1]) != 1) mexErrMsgTxt("d is not scalar.");
    d = *mxGetPr(prhs[1]);
    for(i=0;i<len;i++)
      *outdata++ = gammaln2(*indata++,d);
  }
}

