/* 
mex s_derivatives.c $LIGHTSPEED/util.o -lm
 */
#include "mex.h"
#include <math.h>
#include "util.h"

void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
{
  const mxArray *obj, *pa;
  double *a, *data, *len, *weight;
  int K,N;
  int i,k;
  double s, g, h, c1, c3;
  int sparse = 0, *rowOf, *firstInCol;

  if((nrhs < 3) || (nrhs > 4) || (nlhs != 4)) {
    mexErrMsgTxt("Usage: [g,h,c1,c3] = s_derivatives(a, data, len, weight)");
  }
  /* a is a row or col vector 
   * data is a matrix of rows
   * len is a row or col vector
   * weight is a row or col vector
   */
  pa = prhs[0];
  if(mxGetM(pa) == 1) K = mxGetN(pa);
  else if(mxGetN(pa) == 1) K = mxGetM(pa);
  else mexErrMsgTxt("a is the wrong size");
  a = mxGetPr(pa);

  pa = prhs[1];
  N = mxGetM(pa);
  if(mxGetN(pa) != K)
    mexErrMsgTxt("data is the wrong size");
  data = mxGetPr(pa);
  if(mxIsSparse(pa)) {
    sparse = 1;
    rowOf = mxGetIr(pa);
    firstInCol = mxGetJc(pa);
  }

  if( (mxGetM(prhs[2]) == 1 && mxGetN(prhs[2]) == N) ||
      (mxGetM(prhs[2]) == N && mxGetN(prhs[2]) == 1) ) {
    len = mxGetPr(prhs[2]);
  }
  else mexErrMsgTxt("len is the wrong size");

  if(nrhs > 3) {
    if( (mxGetM(prhs[3]) == 1 && mxGetN(prhs[3]) == N) ||
	(mxGetM(prhs[3]) == N && mxGetN(prhs[3]) == 1) ) {
      weight = mxGetPr(prhs[3]);
    }
    else mexErrMsgTxt("weight is the wrong size");
  }
  else weight = NULL;

  /* c1 is the limiting log(s) coefficient
   * c3 is the limiting 1/s^2 coefficient 
   */
  g = h = c1 = c3 = 0;

  /* compute current s */
  s = 0;
  for(k=0;k<K;k++) s += a[k];
  
  /* loop words */
  for(k=0;k<K;k++) {
    double c3k = 0;
    double m = a[k]/s, m2 = m*m;
    if(m == 0) continue;
    if(!sparse) {
      for(i=0;i<N;i++) {
	double w = 1;
	int count = data[i + k*N];
	if(count == 0) continue;
	if(weight) w = weight[i];
	g += m*di_pochhammer(a[k], count)*w;
	h += m2*tri_pochhammer(a[k], count)*w;
	c1 += w;
	c3k += (double)count*(count-1)*(2*count-1)*w;
      }
    }
    else {
      int index;
      for(index = firstInCol[k]; index < firstInCol[k+1]; index++) {
	double w = 1;
	int count = data[index];
	if(weight) w = weight[rowOf[index]];
	g += m*di_pochhammer(a[k], count)*w;
	h += m2*tri_pochhammer(a[k], count)*w;
	c1 += w;
	c3k += (double)count*(count-1)*(2*count-1)*w;
      }
    }
    c3 -= c3k/m2;
  }
  for(i=0;i<N;i++) {
    int count = len[i];
    if(count > 0) {
      double w = 1;
      if(weight) w = weight[i];
      g -= di_pochhammer(s, count)*w;
      h -= tri_pochhammer(s, count)*w;
      c1 -= w;
      c3 += (double)count*(count-1)*(2*count-1)*w;
    }
  }
  c3 /= 6;
  *mxGetPr(plhs[0] = mxCreateDoubleMatrix(1, 1, mxREAL)) = g;
  *mxGetPr(plhs[1] = mxCreateDoubleMatrix(1, 1, mxREAL)) = h;
  *mxGetPr(plhs[2] = mxCreateDoubleMatrix(1, 1, mxREAL)) = c1;
  *mxGetPr(plhs[3] = mxCreateDoubleMatrix(1, 1, mxREAL)) = c3;
}
