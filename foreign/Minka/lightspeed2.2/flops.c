#include "mex.h"
#include "flops.h"

void addflops(unsigned fl)
{
#if 0
  mxArray *flopcount = mexGetArray("flopcount","global");
  if(flopcount && !mxIsEmpty(flopcount))) {
    *mxGetPr(flopcount) += fl;
    mexPutArray(flopcount,"global");
  }
#else
  /* Matlab 6.5 */
  mxArray *flopcount = mexGetVariable("global","flopcount");
  if(flopcount && !mxIsEmpty(flopcount)) {
    *mxGetPr(flopcount) += fl;
    mexPutVariable("global","flopcount",flopcount);
  }
#endif
}

