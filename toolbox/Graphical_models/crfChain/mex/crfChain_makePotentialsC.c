#include <math.h>
#include "mex.h"

/* See crfChain_loss.m for details! */
/* This function may not exit gracefully on bad input! */
#define submat_value(mat, i, j) mat.value_start[((i)-1) + ((j)-1)*mat.numRows]
#define submat_pointer(mat, i, j) &submat_value(mat, i, j)

typedef struct SubMatrixType
{
	double *value_start;
	unsigned int numRows;
	unsigned int numColumns;

} SubMatrix;
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
	double *wv, *nFeatures;
	unsigned int nStates, nFeaturesTotal, s;
	SubMatrix w, v, v_start, v_end, gw, gv, gv_start, gv_end, sentences, y, X, featureStart, nodePot, edgePot;
	double f = 0;

	X.value_start =  mxGetPr(prhs[0]);
	X.numRows = mxGetM(prhs[0]);
	X.numColumns = mxGetN(prhs[0]);

	wv = mxGetPr(prhs[1]);	

	nFeatures = mxGetPr(prhs[2]);

	featureStart.value_start = mxGetPr(prhs[3]);
	featureStart.numRows = mxGetM(prhs[3]);
	featureStart.numColumns = mxGetN(prhs[3]);

	sentences.value_start = mxGetPr(prhs[4]);
	sentences.numRows = mxGetM(prhs[4]);
	sentences.numColumns = mxGetN(prhs[4]);

	s = mxGetScalar(prhs[5]);

	nStates = mxGetScalar(prhs[6]);

	/*nFeaturesTotal = featureStart(end)-1;*/
	nFeaturesTotal = submat_value(featureStart, 1, featureStart.numColumns) - 1;
	int nSentences = mxGetM(prhs[6]);

	/*Set up the submatrices for node and edge parameters*/
	w.value_start = wv;
	w.numRows = nFeaturesTotal;
	w.numColumns = nStates;
	
	v_start.value_start = wv + nFeaturesTotal*nStates;
	v_start.numRows = nStates;
	v_start.numColumns = 1;
	
	v_end.value_start = wv + nFeaturesTotal*nStates + nStates;
	v_end.numRows = nStates;
	v_end.numColumns = 1;

	v.value_start = wv + nFeaturesTotal*nStates + 2*nStates;
	v.numRows = nStates;
	v.numColumns = nStates;
	
	int nNodes = submat_value(sentences, s, 2) - submat_value(sentences, s, 1) + 1;

	plhs[0] = mxCreateDoubleMatrix(nNodes, nStates, mxREAL);
	nodePot.value_start = mxGetPr(plhs[0]);
	nodePot.numRows = nNodes;
	nodePot.numColumns = nStates;
	
	plhs[1] = mxCreateDoubleMatrix(v.numRows, v.numColumns, mxREAL);
	edgePot.value_start = mxGetPr(plhs[1]);
	edgePot.numRows = v.numRows;
	edgePot.numColumns = v.numColumns;
	
	int n;
	for (n = 1; n <= nNodes; ++n) {
		double features[X.numColumns];
		int k;
		for (k = 1; k <= X.numColumns; ++k) {
			features[k-1] = submat_value(X, (long)submat_value(sentences, s, 1)+(long)n-(long)1, (long)k);
		}

		int state;
		for (state = 1; state <= nStates; ++state) {
			double pot = 0;
			int f;
			for (f = 1; f <= mxGetN(prhs[2]); ++f) {
				if (features[f-1] != 0) {
					int featureParam = submat_value(featureStart, 1, f) + features[f-1] - 1;
					pot += w.value_start[featureParam+nFeaturesTotal*(state-1)-1];
				}
			}
			submat_value(nodePot, n, state) = pot;
		}
	}

	int k;
	for (k = 1; k <= nodePot.numColumns; ++k) {
		submat_value(nodePot, 1, k) += submat_value(v_start, k, 1);
	}

	for (k = 1; k <= nodePot.numColumns; ++k) {
		submat_value(nodePot, nodePot.numRows, k) += submat_value(v_end, k, 1);
	}

	for (k = 0; k < nodePot.numRows*nodePot.numColumns; ++k) {
		nodePot.value_start[k] = exp(nodePot.value_start[k]);
	}
	
	for (k = 0; k < edgePot.numRows*edgePot.numColumns; ++k) {
		edgePot.value_start[k] = exp(v.value_start[k]);
	}
}
