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
    double *wv, *nFeatures, *np, *ep, *Z;
    unsigned int nStates, nFeaturesTotal, maxSentenceLength;
    SubMatrix w, v, v_start, v_end, gw, gv, gv_start, gv_end, sentences, y, X, featureStart;
    double f = 0;
    
    wv = mxGetPr(prhs[0]);
    
    X.value_start =  mxGetPr(prhs[1]);
    X.numRows = mxGetM(prhs[1]);
    X.numColumns = mxGetN(prhs[1]);
    
    y.value_start = mxGetPr(prhs[2]);
    y.numRows = mxGetM(prhs[2]);
    y.numColumns = mxGetN(prhs[2]);
    
    nStates = mxGetScalar(prhs[3]);
    nFeatures = mxGetPr(prhs[4]);
    
    featureStart.value_start = mxGetPr(prhs[5]);
    featureStart.numRows = mxGetM(prhs[5]);
    featureStart.numColumns = mxGetN(prhs[5]);
    
    sentences.value_start = mxGetPr(prhs[6]);
    sentences.numRows = mxGetM(prhs[6]);
    sentences.numColumns = mxGetN(prhs[6]);
    
    maxSentenceLength = mxGetScalar(prhs[7]);
    
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
    
    mxArray *g = mxCreateDoubleMatrix(mxGetM(prhs[0]),mxGetN(prhs[0]),mxREAL);
    /*mxArray *g = prhs[7];*/
    
    gw.value_start = mxGetPr(g);
    gw.numRows = nFeaturesTotal;
    gw.numColumns = nStates;
    
    gv_start.value_start = mxGetPr(g) + nFeaturesTotal*nStates;
    gv_start.numRows = nStates;
    gv_start.numColumns = 1;
    
    gv_end.value_start = gv_start.value_start + nStates;
    gv_end.numRows = nStates;
    gv_end.numColumns = 1;
    
    gv.value_start = gv_end.value_start + nStates;
    gv.numRows = nStates;
    gv.numColumns = nStates;
    
    int i,j, s, n, k, feat, state, state1, state2;
    SubMatrix nodePot, edgePot, nodeBel, edgeBel, alpha, beta;
    nodePot.value_start = mxCalloc(maxSentenceLength*nStates,sizeof(double));
    edgePot.value_start = mxCalloc(nStates*nStates,sizeof(double));
        nodeBel.value_start = mxCalloc(maxSentenceLength*nStates,sizeof(double));
        edgeBel.value_start = mxCalloc(nStates*nStates*(maxSentenceLength-1),sizeof(double));
        alpha.value_start = mxCalloc(maxSentenceLength*nStates, sizeof(double));
        beta.value_start  = mxCalloc(maxSentenceLength*nStates, sizeof(double));
        Z = mxCalloc(maxSentenceLength,sizeof(double));
    for (s = 1; s <= nSentences; ++s) {
        int nNodes = submat_value(sentences, s, 2) - submat_value(sentences, s, 1) + 1;
        
        SubMatrix y_s;
        y_s.value_start = submat_pointer(y, (long)submat_value(sentences, s, 1), 1);
        y_s.numRows = submat_value(sentences, s, 2) - submat_value(sentences, s, 1) + 1;
        y_s.numColumns = 1;
        
        /*******************************************************************************/
        /* Make nodePot/edgePot */
        
        nodePot.numRows = nNodes;
        nodePot.numColumns = nStates;
        
        edgePot.numRows = v.numRows;
        edgePot.numColumns = v.numColumns;
        
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
                for (f = 1; f <= mxGetN(prhs[4]); ++f) {
                    if (features[f-1] != 0) {
                        int featureParam = submat_value(featureStart, 1, f) + features[f-1] - 1;
                        pot += w.value_start[featureParam+nFeaturesTotal*(state-1)-1];
                    }
                }
                submat_value(nodePot, n, state) = pot;
            }
        }
        
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
        
        
            
        /*******************************************************************************/
        
        /*******************************************************************************/
        /* Infer */
        
        nodeBel.numRows = nodePot.numRows;
        nodeBel.numColumns = nodePot.numColumns;
        
        edgeBel.numRows = nStates;
        edgeBel.numColumns = nStates;
        edgeBel.numMatrices = nNodes - 1;
        
        alpha.numRows = nNodes;
        alpha.numColumns = nStates;
        
        beta.numRows = nNodes;
        beta.numColumns = nStates;
        for (n=0; n< nNodes*nStates;n++)
            beta.value_start[n] = 0;
        
        for (n=0; n < nNodes;n++)
        Z[n]=0;;
        
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
        
        /*******************************************************************************/
        
        for (n = 1; n <= nNodes; ++n) {
            f += log(submat_value(nodePot, n, (long)submat_value(y_s, n, 1)));
        }
        
        for (n = 1; n <= nNodes - 1; ++n) {
            f += log(submat_value(edgePot, (long)submat_value(y_s, n, 1), (long)submat_value(y_s, n+1, 1)));
        }
        
        f -= logZ;
        
        /*Update gradient of node features*/
        for (n = 1; n <= nNodes; ++n) {
            double features[X.numColumns];
            int k;
            for (k = 1; k <= X.numColumns; ++k) {
                features[k-1] = submat_value(X, (long)submat_value(sentences, s, 1)+(long)n-(long)1, (long)k);
            }
            
            for (feat = 1; feat <= mxGetN(prhs[4]); ++feat) {
                if (features[feat-1] != 0) {
                    int featureParam = submat_value(featureStart, 1, feat) + features[feat-1] - 1;
                    for (state = 1; state <= nStates; ++state) {
                        int O = (state == submat_value(y_s, n, 1));
                        double E = submat_value(nodeBel, n, state);
                        submat_value(gw, featureParam, state) += O - E;
                    }
                }
            }
        }
        
        /*Update gradient of BoS and EoS transitions*/
        for (state = 1; state <= nStates; ++state) {
            int O = (state == submat_value(y_s, 1, 1));
            double E = submat_value(nodeBel, 1, state);
            submat_value(gv_start, state, 1) += O - E;
            
            O = (state == submat_value(y_s, y_s.numRows, 1));
            E = submat_value(nodeBel, nodeBel.numRows, state);
            submat_value(gv_end, state, 1) += O - E;
        }
        
        /*GOOD TO HERE*/
        /*Update gradient of transitions*/
        for (n = 1; n <= nNodes - 1; ++n) {
            for (state1 = 1; state1 <= nStates; ++state1) {
                for (state2 = 1; state2 <= nStates; ++state2) {
                    int O = ((state1 == submat_value(y_s, n, 1)) && (state2 == submat_value(y_s, n+1, 1)));
                    double E = edgeBel.value_start[(state1-1) + edgeBel.numRows*((state2-1) + edgeBel.numColumns*(n-1))];
                    submat_value(gv, state1, state2) += O - E;
                }
            }
        }
    }
    double* temp = mxGetPr(g);
    for (n = 1; n <= mxGetM(g); ++n) {
        *temp *= -1;
        temp += 1;
    }
    plhs[0] = mxCreateDoubleScalar(-f);
    plhs[1] = g;
    
        mxFree(nodePot.value_start);
        mxFree(edgePot.value_start);
        mxFree(nodeBel.value_start);
        mxFree(edgeBel.value_start);
        mxFree(alpha.value_start);
        mxFree(beta.value_start);
        mxFree(Z);
}
