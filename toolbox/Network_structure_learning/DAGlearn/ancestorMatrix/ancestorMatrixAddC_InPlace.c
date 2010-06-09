#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>
#include "ancestorMatrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    double *ancMatrix;
    int nc,nr,i,j,p,source,sink;
    
    ancMatrix = mxGetPr(prhs[0]);
    nc = mxGetN(prhs[0]);
    nr = mxGetM(prhs[0]);
    source = mxGetScalar(prhs[1])-1;
    sink = mxGetScalar(prhs[2])-1;
    
	add(ancMatrix,ancMatrix,nr,source,sink);
    
}
