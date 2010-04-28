/* sq_dist - a mex function to compute a matrix of all pairwise squared
   distances between two sets of vectors, stored in the columns of the two 
   matrices that are arguments to the function. The length of the vectors must
   agree. If only a single argument is given, the missing argument is taken to
   be identical to the first. If an optional third matrix argument Q is given,
   it must be of the same size as the output, but in this case a vector of the
   traces of the product of Q and the coordinatewise squared distances is
   returned.

   Copyright (c) 2003, 2004 Carl Edward Rasmussen. 2003-04-22. */
 
#include "mex.h"
#include <math.h>
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
  double *a, *b, *C, *Q, z, t;
  int    D, n, m, i, j, k;
  if (nrhs < 1 || nrhs > 3 || nlhs > 1)
    mexErrMsgTxt("Usage: C = sq_dist(a,b)\n       or: C = sq_dist(a)\n       or: c = sq_dist(a,b,Q)\nwhere the b matrix may be empty.");
  a = mxGetPr(prhs[0]);
  m = mxGetN(prhs[0]);
  D = mxGetM(prhs[0]);
  if (nrhs == 1 || mxIsEmpty(prhs[1])) {
    b = a;
    n = m;
  } else {
    b = mxGetPr(prhs[1]);
    n = mxGetN(prhs[1]);
    if (D != mxGetM(prhs[1]))
      mexErrMsgTxt("Error: column lengths must agree");
  }
  if (nrhs < 3) {
    plhs[0] = mxCreateDoubleMatrix(m, n, mxREAL);
    C = mxGetPr(plhs[0]);
    for (i=0; i<m; i++) for (j=0; j<n; j++) {
      z = 0.0;
      for (k=0; k<D; k++) { t = a[D*i+k] - b[D*j+k]; z += t*t; }
      C[i+j*m] = z;
    }
  } else {
    Q = mxGetPr(prhs[2]);
    if (mxGetN(prhs[2]) != n || mxGetM(prhs[2]) != m)
	mexErrMsgTxt("Error: 3rd matrix argument has wrong dimensions");
    plhs[0] = mxCreateDoubleMatrix(D, 1, mxREAL);
    C = mxGetPr(plhs[0]);
    for (k=0; k<D; k++) C[k] = 0.0;
    for (i=0; i<m; i++) for (j=0; j<n; j++) {
      t = Q[i+j*m];
      for (k=0; k<D; k++) {
        z = a[i*D+k] - b[j*D+k]; C[k] += t*z*z;
      }
    }
  }
}
