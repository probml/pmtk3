#include "mex.h"

/* Returns the interpolated output value at index, i.e. (index, value)
 * using the known (inp, outp) pairs.
 */
void table1(double *inp, double *outp, int length, double index,
	    int output_length, double *value_return, int stride)
{
  int i,j;
  double k;
  /* find the first element of inp greater than index */
#if 1
  for(i=0;i<length;i++) {
    if(inp[i] > index) break;
  }
#else
  /* binary search */
  int low = 0, high = length;
  while(low < high) {
    i = (high+low)/2;
    if(inp[i] >= index) high = i;
    else if(inp[i] < index) low = i+1;
  }
#endif
  /* too small or large? guess the extreme value */
  if(i == 0) { 
    k = 1; 
    for(j=0;j<output_length;j++) {
      *value_return = outp[i];
      value_return += stride;
      outp += length;
    }
  }
  else if(i == length) { 
    k = 0; 
    for(j=0;j<output_length;j++) {
      *value_return = outp[i-1];
      value_return += stride;
      outp += length;
    }
  }
  else {
    /* interpolate between this element and the previous one */
    k = (index - inp[i-1]) / (inp[i] - inp[i-1]);
    for(j=0;j<output_length;j++) {
      *value_return = k*outp[i] + (1-k)*outp[i-1];
      value_return += stride;
      outp += length;
    }
  }
}

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  double *pr;
  int length, data_length, nx, i;

  if((nrhs != 2) || (nlhs > 1)) mexErrMsgTxt("Usage: y = table1(tab, x)");
  pr = mxGetPr(prhs[0]);
  length = mxGetM(prhs[0]);
  data_length = mxGetN(prhs[0])-1;
  nx = mxGetM(prhs[1]);
  if(mxGetN(prhs[1]) > nx) nx = mxGetN(prhs[1]);
  plhs[0] = mxCreateDoubleMatrix(nx, data_length, REAL);
  for(i=0;i<nx;i++) {
    table1(pr, pr+length, length, mxGetPr(prhs[1])[i], 
	   data_length, mxGetPr(plhs[0])+i, nx);
  }
}
