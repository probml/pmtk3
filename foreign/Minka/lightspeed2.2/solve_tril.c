/* see solve_triu for compilation instructions.
 */
#include "mex.h"
#include <string.h>

#ifdef UNDERSCORE_LAPACK_CALL
/* Thanks to Ruben Martinez-Cantin */
extern int dtrsm_(char *side, char *uplo, char *transa, char *diag, 
		  int *m, int *n, double *alpha, double *a, int *lda, 
		  double *b, int *ldb);
#else
extern int dtrsm(char *side, char *uplo, char *transa, char *diag, 
		  int *m, int *n, double *alpha, double *a, int *lda, 
		  double *b, int *ldb);
#endif

void mexFunction(int nlhs, mxArray *plhs[],
		 int nrhs, const mxArray *prhs[])
{
  int m,n;
  double *T,*b,*x;
  char side='L',uplo='L',trans='N',diag='N';
  double one = 1;

  if(nrhs != 2 || nlhs > 1)
    mexErrMsgTxt("Usage: x = solve_tril(T,b)");

  /* prhs[0] is first argument.
   * mxGetPr returns double*  (data, col-major)
   * mxGetM returns int  (rows)
   * mxGetN returns int  (cols)
   */
  /* m = rows(T) */
  m = mxGetM(prhs[0]);
  n = mxGetN(prhs[0]);
  if(m != n) mexErrMsgTxt("matrix must be square");
  /* n = cols(b) */
  n = mxGetN(prhs[1]);
  T = mxGetPr(prhs[0]);
  b = mxGetPr(prhs[1]);

  if(mxIsSparse(prhs[0]) || mxIsSparse(prhs[1])) {
    mexErrMsgTxt("Sorry, can't handle sparse matrices yet.");
  }
  if(mxGetNumberOfDimensions(prhs[0]) != 2) {
    mexErrMsgTxt("Arguments must be matrices.");
  }
  if(mxGetNumberOfDimensions(prhs[1]) != 2) {
    mexErrMsgTxt("Arguments must be matrices.");
  }

  /* plhs[0] is first output */
  /* x is same size as b */
  plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
  x = mxGetPr(plhs[0]);
  /* copy b into x to speed up memory access */
  memcpy(x,b,m*n*sizeof(double));
  b = x;

#ifdef UNDERSCORE_LAPACK_CALL
  dtrsm_(&side,&uplo,&trans,&diag,&m,&n,&one,T,&m,x,&m);
#else
  dtrsm(&side,&uplo,&trans,&diag,&m,&n,&one,T,&m,x,&m);
#endif

}

#if 0
  /* Upper triangular */
  for(j=0;j<n;j++) x[m-1 + m*j] = b[m-1 + m*j]/T[m*m - 1];
  for(i=m-2;i>=0;i--) {
    for(j=0;j<n;j++) {
      double s = 0;
      for(k=i+1;k<m;k++) {
	s += T[i + m*k]*x[k + m*j];
      }
      x[i + m*j] = (b[i + m*j] - s)/T[i + m*i];
    }
  }    
  /* Lower triangular */
  for(j=0;j<n;j++) x[m*j] = b[m*j]/T[0];
  for(i=1;i<m;i++) {
    for(j=0;j<n;j++) {
      double s = 0;
      for(k=0;k<i;k++) {
	s += T[i + m*k]*x[k + m*j];
      }
      x[i + m*j] = (b[i + m*j] - s)/T[i + m*i];
    }
  }
#endif
