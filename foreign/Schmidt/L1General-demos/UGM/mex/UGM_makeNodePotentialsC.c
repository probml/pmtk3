#include <math.h>
#include "mex.h"
#include "UGM_common.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Variables */
    int i, n, p, s, tied, nInstances, nFeatures, nNodes, maxState, sizeNodePot[3],*nStates;
    
    double *X, *w, *nodePot, temp;
    
    /* Input */
    
    i = 0;
    X = mxGetPr(prhs[0]);
    w = mxGetPr(prhs[1]);
    nStates = mxGetPr(prhs[2]);
    tied = mxGetScalar(prhs[3]);
    
    /* Sizes */
    nInstances = mxGetDimensions(prhs[0])[0];
    nFeatures = mxGetDimensions(prhs[0])[1];
    nNodes = mxGetDimensions(prhs[0])[2];
    maxState = getMaxState(nStates,nNodes);
    
    /* Debugging */
   /*         printf("Tied = %d\n",tied);
    for(n = 0; n < nNodes; n++)
    {
        printf("nStates(%d) = %d\n",n,nStates[n]);
    }
    printf("Max State = %d\n",maxState);*/
    
    
    /* Output */
    
    sizeNodePot[0] = nNodes;
    sizeNodePot[1] = maxState;
    sizeNodePot[2] = nInstances;
    plhs[0] = mxCreateNumericArray(3,sizeNodePot,mxDOUBLE_CLASS,mxREAL);
    nodePot = mxGetPr(plhs[0]);
    
    
    /* Compute Node Potentials */
    
    for(i = 0; i < nInstances; i++)
    {
        for(n = 0; n < nNodes; n++)
        {
            if (tied)
            {
                for(s = 0; s < maxState-1; s++)
                {
                    temp = 0;
                    for(p = 0; p < nFeatures; p++)
                    {
                        temp = temp + X[i + nInstances*(p + nFeatures*n)]*w[p + nFeatures*s];
                    }
                    nodePot[n + nNodes*(s + maxState*i)] = exp(temp);
                }
                nodePot[n + nNodes*(maxState-1 + maxState*i)] = 1;
            }
            else
            {
                for(s = 0; s < nStates[n]-1; s++)
                {
                    temp = 0;
                    for(p=0; p < nFeatures; p++)
                    {
                        temp = temp + X[i + nInstances*(p + nFeatures*n)]*w[p + nFeatures*(s + (maxState-1)*n)];
                    }
                    nodePot[n + nNodes*(s + maxState*i)] = exp(temp);
                }
                nodePot[n + nNodes*(nStates[n]-1 + maxState*i)] = 1;
            }
        }
    }
}
