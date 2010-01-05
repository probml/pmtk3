#include <math.h>
#include "mex.h"
#include "UGM_common.h"

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* Variables */
    int i,n,s,e,*y,*edgeEnds,outputSize[2],
    nNodes,maxState,nInstances,nEdges;
    
    double *nodePot,*edgePot,*fsub;
    
    /* Input */
    y = mxGetPr(prhs[0]);
    nodePot = mxGetPr(prhs[1]);
    edgePot = mxGetPr(prhs[2]);
    edgeEnds = mxGetPr(prhs[3]);
    
    /* Compute Sizes */
    nInstances = mxGetDimensions(prhs[0])[0];
    nNodes = mxGetDimensions(prhs[1])[0];
    maxState = mxGetDimensions(prhs[1])[1];
    nEdges = mxGetDimensions(prhs[3])[0];
    decrementEdgeEnds(edgeEnds,nEdges);
    
    /* Output */
    outputSize[0] = 1;
    outputSize[1] = 1;
    plhs[0] = mxCreateNumericArray(2,outputSize,mxDOUBLE_CLASS,mxREAL);
    fsub = mxGetPr(plhs[0]);
    
    /* Decrement y */
    for(i = 0; i < nInstances; i++)
    {
        for(n = 0; n < nNodes; n++)
        {
            y[i + nInstances*n]--;
        }
    }
    
    fsub[0] = 0;
    
    /* Reference into nodePot like this: nodePot[n+nNodes*(s+maxState*i)] */
    /* Reference into edgePot like this: edgePot[s1+maxState*(s2+maxState*(e+nEdges*i))] */
    
    /* Update based on Node Potentials of Training Labels */
    for(i = 0; i < nInstances; i++)
    {
        for(n = 0; n < nNodes; n++)
        {
            fsub[0] -= log(nodePot[n+nNodes*y[i+nInstances*n]]);
        }
    }
    
    /* Update based on Edge Potentials of Training Labels */
    for(i = 0; i < nInstances; i++)
    {
        for(e = 0; e < nEdges; e++)
        {
            fsub[0] -= log(edgePot[y[i+nInstances*edgeEnds[e]]+maxState*(y[i+nInstances*edgeEnds[e+nEdges]]+maxState*e)]);
        }
    }

}
