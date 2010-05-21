#include <math.h>
#include "mex.h"

/* See crfChain_loss.m for details! */
/* This function may not exit gracefully on bad input! */
#define submat_value(mat, i, j) mat.value_start[((i)-1) + ((j)-1)*mat.numRows]
#define submat_pointer(mat, i, j) &submat_value(mat, i, j)
#define submat_value3(mat, i, j, k) mat.value_start[((i)-1) + mat.numRows*(((j)-1) + ((k)-1)*mat.numColumns)]
#define submat_pointer3(mat, i, j, k) &submat_value(mat, i, j, k)

typedef struct SubMatrixType
{
	double *value_start;
	unsigned int numRows;
	unsigned int numColumns;
	unsigned int numMatrices;
} SubMatrix;
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	SubMatrix nodePot, edgePot, alpha, beta, nodeBel, edgeBel;
	double* Z;
	int i, j, n, nNodes, nStates;
	
	nodePot.value_start = mxGetPr(prhs[0]);
	nodePot.numRows = mxGetM(prhs[0]);
	nodePot.numColumns = mxGetN(prhs[0]);
	
	edgePot.value_start = mxGetPr(prhs[1]);
	edgePot.numRows = mxGetM(prhs[1]);
	edgePot.numColumns = mxGetN(prhs[1]);

	plhs[0] = mxCreateDoubleMatrix(nodePot.numRows, nodePot.numColumns, mxREAL);
	nodeBel.value_start = mxGetPr(plhs[0]);
	nodeBel.numRows = nodePot.numRows;
	nodeBel.numColumns = nodePot.numColumns;
	
	nNodes = nodePot.numRows;
	nStates = nodePot.numColumns;

	unsigned int edgeBelDims[3] = { nStates, nStates, nNodes - 1 };
	plhs[1] = mxCreateNumericArray(3, edgeBelDims, mxDOUBLE_CLASS, mxREAL);
	edgeBel.value_start = mxGetPr(plhs[1]);
	edgeBel.numRows = nStates;
	edgeBel.numColumns = nStates;
	edgeBel.numMatrices = nNodes - 1;

	alpha.value_start = mxCalloc(nNodes*nStates, sizeof(double));
	alpha.numRows = nNodes;
	alpha.numColumns = nStates;

	beta.value_start = mxCalloc(nNodes*nStates, sizeof(double));
	beta.numRows = nNodes;
	beta.numColumns = nStates;
	
	Z = mxCalloc(nNodes, sizeof(double));

	
	for (i = 1; i <= alpha.numColumns; ++i) {
		submat_value(alpha, 1, i) = submat_value(nodePot, 1, i);
	}

	for (i = 1; i <= alpha.numColumns; ++i) {
		Z[0] += submat_value(alpha, 1, i);
	}

	for (i = 1; i <= alpha.numColumns; ++i) {
		submat_value(alpha, 1, i) /= Z[0];
	}

	for (n = 2; n <= nNodes; ++n) {
		double tmp[edgePot.numColumns];
		for (i = 0; i < edgePot.numColumns; ++i) {
			tmp[i] = 0;
		}
		for (i = 1; i <= alpha.numColumns; ++i) {
			for (j = 1; j <= nStates; ++j) {
				tmp[j-1] += submat_value(alpha, n-1, i)*submat_value(edgePot, i, j); 
			}
		}
		
		for (i = 1; i <= alpha.numColumns; ++i) {
			submat_value(alpha, n, i) = submat_value(nodePot, n, i)*tmp[i-1];
		}

		for (i = 1; i <= alpha.numColumns; ++i) {
			Z[n-1] += submat_value(alpha, n, i);
		}

		for (i = 1; i <= alpha.numColumns; ++i) {
			submat_value(alpha, n, i) /= Z[n-1];
		}
	}

	for (i = 1; i<= nStates; ++i) {
		submat_value(beta, nNodes, i) = 1;
	}

	for (n = nNodes - 1; n >= 1; --n) {
		for (j = 1; j <= nodePot.numColumns; ++j) {
			for (i = 1; i <= nStates; ++i) {
				submat_value(beta, n, i) += submat_value(nodePot, n+1, j)*submat_value(edgePot, i, j)*submat_value(beta, n+1, j);
			}
		}

		double tmp = 0;
		for (i = 1; i <= beta.numColumns; ++i) {
			tmp += submat_value(beta, n, i);
		}
		for (i = 1; i <= beta.numColumns; ++i) {
			submat_value(beta, n, i) /= tmp;
		}
	}

	for (n = 1; n <= nNodes; ++n) {
		double tmp[alpha.numColumns];
		for (i = 0; i < alpha.numColumns; ++i) {
			tmp[i] = 0;
		}
		
		double sumTmp = 0;
		for (i = 1; i <= alpha.numColumns; ++i) {
			tmp[i-1] += submat_value(alpha, n, i)*submat_value(beta, n, i);
			sumTmp += tmp[i-1];
		}

		for (i = 1; i <= alpha.numColumns; ++i) {
			submat_value(nodeBel, n, i) = tmp[i-1]/sumTmp;
		}
	}

	for (n = 1; n <= nNodes-1; ++n) {
		double sum = 0;
		for (i = 1; i <= nStates; ++i) {
			for (j = 1; j <= nStates; ++j) {
				submat_value3(edgeBel, i, j, n) = submat_value(alpha, n, i)*submat_value(nodePot, n+1, j)*submat_value(beta, n+1, j)*submat_value(edgePot, i, j);
				sum += submat_value3(edgeBel, i, j, n);
			}
		}

		for (i = 1; i <= nStates; ++i) {
			for (j = 1; j <= nStates; ++j) {
				submat_value3(edgeBel, i, j, n) /= sum;
			}
		}
	}

	double logZ = 0;

	for (i = 0; i < nNodes; ++i) {
		logZ += log(Z[i]);
	}
	
	plhs[2] = mxCreateDoubleScalar(logZ);

	mxFree(alpha.value_start);
	mxFree(beta.value_start);
	mxFree(Z);
}
