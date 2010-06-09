#include "mex.h"

#include <string.h>
#include <stdio.h>
#include <math.h>
#include <ctype.h>
#include "ancestorMatrix.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    
    double *adjMatrix, *ancMatrix;
    int nc,nr,i,j;
    
    adjMatrix = mxGetPr(prhs[0]);
    nc = mxGetN(prhs[0]);
    nr = mxGetM(prhs[0]);
    
    plhs[0] = mxCreateDoubleMatrix( nr, nc, mxREAL );
    ancMatrix = mxGetPr(plhs[0]);
    
	for(i = 0; i < nr; i++)
	{
		for(j = 0; j < nc; j++)
		{
			if (adjMatrix[i + nr*j] == 1)
				add(ancMatrix,ancMatrix,nr,i,j);
		}
	}

}
