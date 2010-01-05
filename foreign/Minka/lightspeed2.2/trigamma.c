/* compile with: cmex trigamma.c util.c -lm
 * test in matlab:
 *   trigamma(1:10)
 */
#include "mex.h"
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int ndims, len, i, nnz;
  int *dims;
  double *indata, *outdata;

  if((nrhs != 1) || (nlhs > 1))    
    mexErrMsgTxt("Usage: x = trigamma(n)");

  /* prhs[0] is first argument.
   * mxGetPr returns double*  (data, col-major)
   * mxGetM returns int  (rows)
   * mxGetN returns int  (cols)
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

  /* compute trigamma of every element */
  for(i=0;i<len;i++)
    *outdata++ = trigamma(*indata++);
}

