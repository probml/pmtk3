/*
 * INT_HIST(x, n) is a histogram of all integer values 1..n in x.
 * If n is not given, max(x) is used.
 */
#include "mex.h"
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int rows, cols, len, i, bins;
  double *indata, *outdata;

  if((nrhs < 1) || (nrhs > 2))
    mexErrMsgTxt("Usage: h = int_hist(x, n)");

  /* prhs[0] is first argument.
   * mxGetPr returns double*  (data, col-major)
   * mxGetM returns int  (rows)
   * mxGetN returns int  (cols)
   */
  rows = mxGetM(prhs[0]);
  cols = mxGetN(prhs[0]);
  indata = mxGetPr(prhs[0]);
  len = rows*cols;

  if(mxIsSparse(prhs[0]))
    mexErrMsgTxt("Cannot handle sparse matrices.  Sorry.");

  if(nrhs == 2) {
    if(mxGetNumberOfElements(prhs[1]) != 1) mexErrMsgTxt("n is not scalar.");
    bins = *mxGetPr(prhs[1]);
  } else {
    bins = indata[0];
    for(i=0;i<len;i++) {
      if(indata[i] > bins) bins = indata[i];
    }
  }

  /* plhs[0] is first output */
  plhs[0] = mxCreateDoubleMatrix(1, bins, mxREAL);
  outdata = mxGetPr(plhs[0]);

  for(i=0;i<len;i++) {
    int v = (int)(*indata++) - 1;
    if((v < 0) || (v >= bins))
      mexErrMsgTxt("value out of bounds");
    outdata[v]++;
  }
}

