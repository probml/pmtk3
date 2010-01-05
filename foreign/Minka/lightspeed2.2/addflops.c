#include "mex.h"
#include "flops.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  if(nrhs != 1) mexErrMsgTxt("Usage: addflops(count)");
  if(mxGetNumberOfElements(prhs[0]) != 1)
    mexErrMsgTxt("flop count is not scalar");
  addflops((unsigned)*mxGetPr(prhs[0]));
}
