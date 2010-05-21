#include <math.h>
#include "mex.h"
#include "UGM_common.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int n, s,s1,s2,e, nEdges,
    nNodes, maxState, sizeEdgeBel[3], sizeLogZ[2],
    *nStates;
    
    double Z,*kappa,*tmp,*tmp2,sum_tmp,
    *nodePot, *edgePot, *nodeBel, *edgeBel, *logZ, *alpha, *beta;
    
   /* Input */
    
    nodePot = mxGetPr(prhs[0]);
    edgePot = mxGetPr(prhs[1]);
    nStates = mxGetPr(prhs[2]);
    
   /* Compute Sizes */
    
    nNodes = mxGetDimensions(prhs[0])[0];
    maxState = mxGetDimensions(prhs[0])[1];
    nEdges = nNodes-1;
    
   /* Output */
    sizeEdgeBel[0] = maxState;
    sizeEdgeBel[1] = maxState;
    sizeEdgeBel[2] = nEdges;
    sizeLogZ[0] = 1;
    sizeLogZ[1] = 1;
    plhs[0] = mxCreateNumericArray(2,mxGetDimensions(prhs[0]),mxDOUBLE_CLASS,mxREAL);
    plhs[1] = mxCreateNumericArray(3,sizeEdgeBel,mxDOUBLE_CLASS,mxREAL);
    plhs[2] = mxCreateNumericArray(2,sizeLogZ,mxDOUBLE_CLASS,mxREAL);
    nodeBel = mxGetPr(plhs[0]);
    edgeBel = mxGetPr(plhs[1]);
    logZ = mxGetPr(plhs[2]);
    
   /* Initialize */
    alpha = mxCalloc(nNodes*maxState,sizeof(double));
    beta = mxCalloc(nNodes*maxState,sizeof(double));
    kappa = mxCalloc(nNodes,sizeof(double));
    tmp = mxCalloc(maxState*maxState,sizeof(double));
    tmp2 = mxCalloc(maxState*maxState,sizeof(double));
    
    for(s = 0; s < nStates[0]; s++) {
        alpha[nNodes*s] = nodePot[nNodes*s];
        kappa[0] += alpha[nNodes*s];
    }
    for(s = 0; s < nStates[0]; s++) {
        alpha[nNodes*s] /= kappa[0];
    }
    
   /* Forward Pass */
    for(n = 1; n < nNodes;n++) {
        for(s1 = 0; s1 < nStates[n-1];s1++) {
            for(s2 = 0; s2 < nStates[n];s2++) {
                tmp[s1 + maxState*s2] = alpha[n-1 + nNodes*s1]*edgePot[s1 + maxState*(s2 + maxState*(n-1))];
            }
        }
        for(s2 = 0; s2 < nStates[n];s2++) {
            sum_tmp = 0;
            for(s1 = 0; s1 < nStates[n-1];s1++) {
                sum_tmp += tmp[s1 + maxState*s2];
            }
            alpha[n + nNodes*s2] = nodePot[n + nNodes*s2]*sum_tmp;
            kappa[n] += alpha[n + nNodes*s2];
        }
        for(s = 0; s < nStates[n];s++) {
            alpha[n + nNodes*s] /= kappa[n];
        }
    }
    /*for(n = 0;n < nNodes; n++)
    {
        printf("alpha[%d,:] = ",n+1);
        for(s = 0; s < maxState;s++)
        {
            printf("%f ",alpha[n+nNodes*s]);
        }
        printf("\n");
    }*/
    
    /* Backward Pass */
    for(s = 0; s < nStates[nNodes-1]; s++)
    {
       beta[nNodes-1 + nNodes*s] = 1;
    }
    for(n = nNodes-2; n >= 0; n--) {
        for(s1 = 0; s1 < nStates[n]; s1++) {
            for(s2 = 0; s2 < nStates[n+1]; s2++) {
                tmp[s1 + maxState*s2] = nodePot[n+1 + nNodes*s2]*edgePot[s1 + maxState*(s2 + maxState*n)];
                tmp2[s1 + maxState*s2] = beta[n+1 + nNodes*s2];
            }
        }
        Z = 0;
        for(s1 = 0; s1 < nStates[n]; s1++) {
            sum_tmp = 0;
            for(s2 = 0; s2 < nStates[n+1]; s2++) {
                sum_tmp += tmp[s1 + maxState*s2]*tmp2[s1 + maxState*s2];
            }
            beta[n + nNodes*s1] = sum_tmp;
            Z += sum_tmp;
        }
        for(s = 0; s < nStates[n]; s++) {
            beta[n + nNodes*s] /= Z;
        }
    }
    
    /*for(n = 0;n < nNodes; n++)
    {
        printf("beta[%d,:] = ",n+1);
        for(s = 0; s < maxState;s++)
        {
            printf("%f ",beta[n+nNodes*s]);
        }
        printf("\n");
    }*/
    
    /* Compute nodeBel */
    for(n = 0; n < nNodes; n++) {
        Z = 0;
        for(s = 0; s < nStates[n]; s++) {
            tmp[s] = alpha[n + nNodes*s]*beta[n + nNodes*s];
            Z += tmp[s];
        }
        for(s = 0; s < nStates[n]; s++) {
            nodeBel[n + nNodes*s] = tmp[s]/Z;
        }
    }
    
    /* Compute edgeBel */
    for(n = 0; n < nNodes-1; n++) {
        Z = 0;
        for(s1 = 0; s1 < nStates[n]; s1++) {
            for(s2 = 0; s2 < nStates[n+1]; s2++) {
                tmp[s1 + maxState*s2] = alpha[n + nNodes*s1]*nodePot[n+1 + nNodes*s2]*beta[n+1 + nNodes*s2]*edgePot[s1 + maxState*(s2 + maxState*n)];
                Z += tmp[s1 + maxState*s2];
            }
        }
        for(s1 = 0; s1 < nStates[n]; s1++) {
            for(s2 = 0; s2 < nStates[n+1]; s2++) {
                edgeBel[s1 + maxState*(s2 + maxState*n)] = tmp[s1 + maxState*s2]/Z;
            }
        }
    }
    
    /* Compute logZ */
    for(n = 0; n < nNodes; n++)
    {
        *logZ += log(kappa[n]);
    }
    
   /* Free memory */
    mxFree(alpha);
    mxFree(beta);
    mxFree(kappa);
    mxFree(tmp);
    mxFree(tmp2);
}
