#include <math.h>
#include "mex.h"
#include "UGM_common.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[]) {
    /* Variables */
    int i, n, n1, n2, p, s, s1, s2, e, tied, ising, nInstances, nFeatures, nNodes, nEdges, maxState,
            sizeEdgePot[4], *nStates, *edgeEnds;
    
    double *Xedge, *v, *edgePot, temp;
    
    /* Input */
    
    i = 0;
    Xedge = mxGetPr(prhs[0]);
    v = mxGetPr(prhs[1]);
    edgeEnds = mxGetPr(prhs[2]);
    nStates = mxGetPr(prhs[3]);
    tied = mxGetScalar(prhs[4]);
    ising = mxGetScalar(prhs[5]);
    
    /* Sizes */
    nInstances = mxGetDimensions(prhs[0])[0];
    nFeatures = mxGetDimensions(prhs[0])[1];
    nEdges = mxGetDimensions(prhs[2])[0];
    nNodes = mxGetDimensions(prhs[3])[0];
    maxState = getMaxState(nStates, nNodes);
    decrementEdgeEnds(edgeEnds, nEdges);
    
    /* Output */
    
    sizeEdgePot[0] = maxState;
    sizeEdgePot[1] = maxState;
    sizeEdgePot[2] = nEdges;
    sizeEdgePot[3] = nInstances;
    plhs[0] = mxCreateNumericArray(4, sizeEdgePot, mxDOUBLE_CLASS, mxREAL);
    edgePot = mxGetPr(plhs[0]);
    
    /* Compute Edge Potentials */
    
    for(i = 0; i < nInstances; i++) {
        for (e = 0; e < nEdges; e++) {
            n1 = edgeEnds[e];
            n2 = edgeEnds[e+nEdges];
            
            for(s1 = 0; s1 < nStates[n1]; s1++) {
                for(s2 = 0; s2 < nStates[n2]; s2++) {
                    s = s1+s2*maxState;
                    
                    if (ising == 2) {
                        if (s1 == s2) {
                            temp = 0;
                            for(p = 0; p < nFeatures; p++) {
                                if (tied) {
                                    temp += Xedge[i + nInstances*(p + nFeatures*e)]*v[p + nFeatures*s1];
                                }
                                else {
                                    temp += Xedge[i + nInstances*(p + nFeatures*e)]*v[p + nFeatures*(s1 + maxState*e)];
                                }
                                edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = exp(temp);
                            }
                        }
                        else {
                            /* Off-diagonal term, just set to 1 */
                            edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = 1;
                        }
                    }
                    else if (ising) {
                        if (s1 == s2) {
                            /* Compute (1,1) element */
                            if (s2 == 0) {
                                temp = 0;
                                for(p = 0; p < nFeatures; p++) {
                                    if (tied) {
                                        temp += Xedge[i + nInstances*(p + nFeatures*e)]*v[p];
                                    }
                                    else {
                                        temp += Xedge[i + nInstances*(p + nFeatures*e)]*v[p + nFeatures*e];
                                    }
                                }
                                edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = exp(temp);
                            }
                            else {
                                /* Copy (1,1) element */
                                edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = edgePot[maxState*(maxState*(e + nEdges*i))];
                            }
                        }
                        else {
                            /* Off-diagonal term, just set to 1 */
                            edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = 1;
                        }
                    }
                    else {
                        if (s1 == nStates[n1]-1 && s2 == nStates[n2]-1) {
                            edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = 1;
                        }
                        else {
                            temp = 0;
                            for(p = 0; p < nFeatures; p++) {
                                if (tied) {
                                    temp = temp + Xedge[i + nInstances*(p + nFeatures*e)]*v[p + nFeatures*s];
                                }
                                else {
                                    temp = temp + Xedge[i + nInstances*(p + nFeatures*e)]*v[p + nFeatures*(s + (maxState*maxState-1)*e)];
                                }
                            }
                            edgePot[s1 + maxState*(s2 + maxState*(e + nEdges*i))] = exp(temp);
                        }
                    }
                    
                }
            }
        }
    }
}