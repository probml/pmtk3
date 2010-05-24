/* Written by Tom Minka
 * (c) Microsoft Corporation. All rights reserved.
 */
#include "mexutil.h"
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  mwSize ndims, len, i;
  mwSize *dims;
  double *indata, *outdata;

  if((nlhs > 1) || (nrhs != 1))
    mexErrMsgTxt("Usage: x = randgamma(a)");

  /* prhs[0] is first argument.
   * mxGetPr returns double*  (data, col-major)
   */
  ndims = mxGetNumberOfDimensions(prhs[0]);
  dims = (mwSize*)mxGetDimensions(prhs[0]);
  indata = mxGetPr(prhs[0]);
  len = mxGetNumberOfElements(prhs[0]);

  if(mxIsSparse(prhs[0]))
    mexErrMsgTxt("Cannot handle sparse matrices.  Sorry.");

  /* plhs[0] is first output */
  plhs[0] = mxCreateNumericArrayE(ndims, dims, mxDOUBLE_CLASS, mxREAL);
  outdata = mxGetPr(plhs[0]);

  for(i=0;i<len;i++) {
    *outdata++ = GammaRand(*indata++);
  }
}

