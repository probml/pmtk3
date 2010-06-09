#include <math.h>
#include "mex.h"
#include "UGM_common.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int n, s,done,maxInd,e,n1,n2,Vind,s1,s2,
    nNodes, nEdges, maxState, sizeYmap[3],
    *edgeEnds, *nStates, *V, *E,*y;
    
    double *pot,maxVal,*yMAP,
    *nodePot, *edgePot;
    
   /* Input */
    
    nodePot = mxGetPr(prhs[0]);
    edgePot = mxGetPr(prhs[1]);
    edgeEnds = mxGetPr(prhs[2]);
    nStates = mxGetPr(prhs[3]);
    V = mxGetPr(prhs[4]);
    E = mxGetPr(prhs[5]);
    y = mxGetPr(prhs[6]);
    
   /* Compute Sizes */
    
    nNodes = mxGetDimensions(prhs[0])[0];
    maxState = mxGetDimensions(prhs[0])[1];
    nEdges = mxGetDimensions(prhs[2])[0];
    decrementEdgeEnds(edgeEnds,nEdges);
    decrementVector(V,nNodes+1);
    decrementVector(E,nEdges*2);
    decrementVector(y,nNodes);

   /* Output */
    sizeYmap[0] = nNodes;
    sizeYmap[1] = 1;
    plhs[0] = mxCreateNumericArray(2,sizeYmap,mxDOUBLE_CLASS,mxREAL);
    yMAP = mxGetPr(plhs[0]);
    
   /* Initialize */
    pot = mxCalloc(maxState,sizeof(double));
    
    
   /* Start at Maximum NodePot */
    /*for(n=0;n<nNodes;n++)
    {
        maxVal = -1;
        maxVal = -1;
        for(s=0;s<nStates[n];s++)
        {
            if(nodePot[n + nNodes*s] > maxVal)
            {
                maxVal = nodePot[n + nNodes*s];
                maxInd = s;
            }
        }
        y[n] = maxInd;
    }*/
    
    done = 0;
    while(!done)
    {
        done = 1;
        for(n = 0; n < nNodes; n++)
        {
           /* Compute Node Potential */
            for(s = 0; s < nStates[n]; s++)
            {
                pot[s] = nodePot[n + nNodes*s];
            }
            
           /* Iterate over Neighbors */
            for(Vind = V[n]; Vind < V[n+1]; Vind++)
            {
                e = E[Vind];
                n1 = edgeEnds[e];
                n2 = edgeEnds[e+nEdges];
                 
                /* Multiply Edge Potentials */
                if(n == n1)
                {
                   for(s = 0; s < nStates[n]; s++)
                   {
                        pot[s] *= edgePot[s+maxState*(y[n2] + maxState*e)];
                   }
                    
                }
                else
                {
                    for(s = 0; s < nStates[n]; s++)
                    {
                        pot[s] *= edgePot[y[n1]+maxState*(s + maxState*e)];
                    }
                }
                
            }
            
            
            
           /* Assign to Maximum State */
            maxVal = -1;
            maxVal = -1;
            for(s=0;s<nStates[n];s++)
            {
                if(pot[s] > maxVal)
                {
                    maxVal = pot[s];
                    maxInd = s;
                }
            }
            if (maxInd != y[n])
            {
                y[n] = maxInd;
                done = 0;
            }
            
        }
    }
    
    for(n = 0; n < nNodes; n++)
    {
        yMAP[n] = y[n]+1;
    }
    
    
   /* Free memory */
    mxFree(pot);
}
