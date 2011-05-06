/*
 *  viterbi_path_helper.c
 *  MEX replacement for KPMhmm viterbi_path
 * 2011-05-05 dpwe@ee.columbia.edu after dpcore.c
 * $Header: /Users/dpwe/matlab/KPMhmm/RCS/viterbi_path_helper.c,v 1.1 2011/05/05 17:19:13 dpwe Exp dpwe $
% Copyright (c) 2011 Dan Ellis <dpwe@ee.columbia.edu>
% released under GPL - see file COPYRIGHT
 */
 
#include    <stdio.h>
#include    <math.h>
#include    <ctype.h>
#include    "mex.h"

/* #define DEBUG */

/* #define INF HUGE_VAL */
#define INF DBL_MAX

/* 
if have_viterbi_helper
  [delta, psi, scale] = viterbi_path_helper(prior, transmat, obslik, scaled);
else
  for t=2:T
    for j=1:Q
      [delta(j,t), psi(j,t)] = max(delta(:,t-1) .* transmat(:,j));
      delta(j,t) = delta(j,t) * obslik(j,t);
    end
    if scaled
      [delta(:,t), n] = normalise(delta(:,t));
      scale(t) = 1/n;
    end
  end
end
*/


void
mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    int 	i,j;
    long   	pvl, pvb[16];

#ifdef DEBUG
    mexPrintf("dpcore: Got %d lhs args and %d rhs args.\n", 
	      nlhs, nrhs); 
    for (i=0;i<nrhs;i++) {
	mexPrintf("RHArg #%d is size %d x %d\n", 
		  (long)i, mxGetM(prhs[i]), mxGetN(prhs[i]));
    }
    for (i=0;i<nlhs;i++)
	if (plhs[i]) {
	    mexPrintf("LHArg #%d is size %d x %d\n", 
		      (long)i, mxGetM(plhs[i]), mxGetN(plhs[i]));
	}
#endif /* DEBUG */

    if (nrhs < 4){
	mexPrintf("[D,P,S] = viterbi_helper(O,R,T,C)\n");
	mexPrintf("  O is local cost, R is priors, T is transmat, C is flag to normalize each column\n");
	mexPrintf("  D is matrix of best scores, P returns traceback, S is vector of norm scales\n");
    }

    if (nlhs > 0){
	mxArray  *DMatrix, *PMatrix, *SMatrix;
	int Q, T, t, j, k;
	double *pR, *pD, *pT, *pO, *pC, *pP, *pS;
	int isscaled = 0;
	float sumval = 0;

	Q = mxGetM(prhs[0]);
	T = mxGetN(prhs[0]);
	pO = mxGetPr(prhs[0]);
	pR = mxGetPr(prhs[1]);
	pT = mxGetPr(prhs[2]);
	pC = mxGetPr(prhs[3]);
	if (*pC != 0) { isscaled = 1; }

	/* mexPrintf("Q=%d, T=%d\n", Q, T); */


	DMatrix = mxCreateDoubleMatrix(Q, T, mxREAL);
	pD = mxGetPr(DMatrix);
	PMatrix = mxCreateDoubleMatrix(Q, T, mxREAL);
	pP = mxGetPr(PMatrix);
	SMatrix = mxCreateDoubleMatrix(1, T, mxREAL);
	pS = mxGetPr(SMatrix);
	plhs[0] = DMatrix;
	if (nlhs > 1) {
	    plhs[1] = PMatrix;
	}
	if (nlhs > 2) {
	    plhs[2] = SMatrix;
	}

	/* do dp */
	/* set up first column of D */
	for (k = 0; k < Q; ++k) {
	    float val = *pO++ * *pR++;
	    sumval += val;
	    *pD++ = val;
	    *pP++ = 0;
	}
	if (isscaled) {
	    float scale = 1/sumval;
	    pD -= Q;
	    for (j = 0; j < Q; ++j) {
		*pD++ *= scale;
	    }
	    *pS++ = scale;
	}

	/* do DP */
	for (t = 1; t < T; ++t) {
	    double *pTT = pT;
	    double *pDD = pD - Q;   /* pointer to previous frame */
	    sumval = 0;
	    for (j = 0; j < Q; ++j) {
		int maxpos = -1;
		float maxval = -1e20;
		double *pDDD = pDD;
		/* search all predecessors */
		for (k = 0; k < Q; ++k) {
		    float val = *pDDD++ * *pTT++;
		    if (val > maxval) {
			maxval = val;
			maxpos = k;
		    }
		}
		maxval = maxval * *pO++;
		*pD++ = maxval;
		*pP++ = maxpos+1;  /* +1 because matlab indexes from 1 */
		sumval += maxval;
	    }
	    if (isscaled) {
		float scale = 1/sumval;
		pD -= Q;
		for (j = 0; j < Q; ++j) {
		    *pD++ *= scale;
		}
		*pS++ = scale;
	    }
	}
    }
#ifdef DEBUG
    mexPrintf("dpcore: returning...\n");
#endif /* DEBUG */
}

