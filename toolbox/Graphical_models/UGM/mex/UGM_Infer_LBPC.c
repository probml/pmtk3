#include <math.h>
#include "mex.h"
#include "UGM_common.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int n, s,e,e2,n1,n2,neigh,Vind,Vind2,s1,s2,
    nNodes, nEdges, maxState, sizeEdgeBel[3], sizeLogZ[2],
    iter,maxIter,nNbrs,
    *edgeEnds, *nStates, *V, *E,*y;
    
    double *nodePot, *edgePot, *nodeBel, *edgeBel, *logZ,
    z,energy1,energy2,entropy1,entropy2,*prodMsgs,*oldMsgs,*newMsgs,*tmp;
    
   /* Input */
    
    nodePot = mxGetPr(prhs[0]);
    edgePot = mxGetPr(prhs[1]);
    edgeEnds = mxGetPr(prhs[2]);
    nStates = mxGetPr(prhs[3]);
    V = mxGetPr(prhs[4]);
    E = mxGetPr(prhs[5]);
    maxIter = mxGetPr(prhs[6])[0];
    
   /* Compute Sizes */
    
    nNodes = mxGetDimensions(prhs[0])[0];
    maxState = mxGetDimensions(prhs[0])[1];
    nEdges = mxGetDimensions(prhs[2])[0];
    decrementEdgeEnds(edgeEnds,nEdges);
    decrementVector(V,nNodes+1);
    decrementVector(E,nEdges*2);
    
    
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
    
    
    prodMsgs = mxCalloc(maxState*nNodes,sizeof(double));
    oldMsgs = mxCalloc(maxState*nEdges*2,sizeof(double));
    newMsgs = mxCalloc(maxState*nEdges*2,sizeof(double));
    tmp = mxCalloc(maxState,sizeof(double));
    
    /* Initialize */
    for(e = 0; e < nEdges; e++)
    {
        n1 = edgeEnds[e];
        n2 = edgeEnds[e+nEdges];
        for(s = 0; s < nStates[n2]; s++)
            newMsgs[s+maxState*e] = 1./nStates[n2];
        for(s = 0; s < nStates[n1]; s++)
            newMsgs[s+maxState*(e+nEdges)] = 1./nStates[n1];
    }
    
    
    for(iter = 0; iter < maxIter; iter++)
    {
        
        for(n=0;n<nNodes;n++)
        {
            
            /* Update Messages */
            for(Vind = V[n]; Vind < V[n+1]; Vind++)
            {
                e = E[Vind];
                n1 = edgeEnds[e];
                n2 = edgeEnds[e+nEdges];
                
                /* First part of message is nodePot*/
                for(s = 0; s < nStates[n]; s++)
                    tmp[s] = nodePot[n + nNodes*s];
                
                /* Multiply by messages from neighbors except j */
                for(Vind2 = V[n]; Vind2 < V[n+1]; Vind2++)
                {
                    e2 = E[Vind2];
                    if (e != e2)
                    {
                        if (n == edgeEnds[e2+nEdges])
                        {
                            for(s = 0; s < nStates[n]; s++)
                            {
                                tmp[s] *= newMsgs[s+maxState*e2];
                            }
                        }
                        else
                        {
                            for(s = 0; s < nStates[n]; s++)
                            {
                                tmp[s] *= newMsgs[s+maxState*(e2+nEdges)];
                            }
                        }
                    }
                }
                
                /* Now multiply by edge potential to get new message */
                
                if (n == n2)
                {
                    for(s1 = 0; s1 < nStates[n1]; s1++)
                    {
                        newMsgs[s1+maxState*(e+nEdges)] = 0.0;
                        for(s2 = 0; s2 < nStates[n2]; s2++)
                        {
                            newMsgs[s1+maxState*(e+nEdges)] += tmp[s2]*edgePot[s1+maxState*(s2+maxState*e)];
                        }
                        
                    }
                    
                    /* Normalize */
                    z = 0.0;
                    for(s = 0; s < nStates[n1]; s++)
                        z += newMsgs[s+maxState*(e+nEdges)];
                    for(s = 0; s < nStates[n1]; s++)
                        newMsgs[s+maxState*(e+nEdges)] /= z;
                }
                else
                {
                    for(s2 = 0; s2 < nStates[n2]; s2++)
                    {
                        newMsgs[s2+maxState*e] = 0.0;
                        for(s1 = 0; s1 < nStates[n1]; s1++)
                        {
                            newMsgs[s2+maxState*e] += tmp[s1]*edgePot[s1+maxState*(s2+maxState*e)];
                        }
                        
                    }
                    
                    /* Normalize */
                    z = 0.0;
                    for(s = 0; s < nStates[n2]; s++)
                        z += newMsgs[s+maxState*e];
                    for(s = 0; s < nStates[n2]; s++)
                        newMsgs[s+maxState*e] /= z;
                }
                
            }
            
            
            
            
        }
        
        
        /* oldMsgs = newMsgs */
        z = 0;
        for(s=0;s<maxState;s++)
        {
            for(e=0;e<nEdges*2;e++)
            {
                z += absDif(newMsgs[s+maxState*e],oldMsgs[s+maxState*e]);
                oldMsgs[s+maxState*e] = newMsgs[s+maxState*e];
            }
        }
        
        /* if sum(abs(newMsgs(:)-oldMsgs(:))) < 1e-4; break; */
        if(z < 1e-4)
        {
            break;
        }
        
    }
    
    /*if(iter == maxIter)
    {
        printf("LBP reached maxIter of %d iterations\n",maxIter);
    }
     printf("Stopped after %d iterations\n",iter); */
    
    /* compute nodeBel */
    for(n = 0; n < nNodes; n++)
    {
        for(s = 0; s < nStates[n]; s++)
            prodMsgs[s+maxState*n] = nodePot[n+nNodes*s];
        
        for(Vind = V[n]; Vind < V[n+1]; Vind++)
        {
            e = E[Vind];
            n1 = edgeEnds[e];
            n2 = edgeEnds[e+nEdges];
            
            if (n == n2)
            {
                for(s = 0; s < nStates[n]; s++)
                {
                    prodMsgs[s+maxState*n] *= newMsgs[s+maxState*e];
                }
            }
            else
            {
                for(s = 0; s < nStates[n]; s++)
                {
                    prodMsgs[s+maxState*n] *= newMsgs[s+maxState*(e+nEdges)];
                }
            }
        }
        
        z = 0;
        for(s = 0; s < nStates[n]; s++)
        {
            nodeBel[n + nNodes*s] = prodMsgs[s+maxState*n];
            z = z + nodeBel[n+nNodes*s];
        }
        for(s = 0; s < nStates[n]; s++)
            nodeBel[n + nNodes*s] /= z;
    }
    
    
    /* Compute edgeBel */
    for(e = 0; e < nEdges; e++)
    {
        n1 = edgeEnds[e];
        n2 = edgeEnds[e+nEdges];
        z = 0;
        for(s1 = 0; s1 < nStates[n1]; s1++)
        {
            for(s2 = 0; s2 < nStates[n2]; s2++)
            {
                edgeBel[s1+maxState*(s2+maxState*e)] = nodeBel[n1+nNodes*s1]/newMsgs[s1+maxState*(e+nEdges)];
                edgeBel[s1+maxState*(s2+maxState*e)] *= nodeBel[n2+nNodes*s2]/newMsgs[s2+maxState*e];
                edgeBel[s1+maxState*(s2+maxState*e)] *= edgePot[s1+maxState*(s2+maxState*e)];
                z += edgeBel[s1+maxState*(s2+maxState*e)];
            }
        }
        for(s1 = 0; s1 < nStates[n1]; s1++)
        {
            for(s2 = 0; s2 < nStates[n2]; s2++)
                edgeBel[s1+maxState*(s2+maxState*e)] /= z;
        }
    }

    /* Compute Bethe Free Energy */
    energy1 = 0;
    energy2 = 0;
    entropy1 = 0;
    entropy2 = 0;
    for(n = 0; n < nNodes; n++)
    {
        nNbrs = V[n+1]-V[n];
        for(s = 0; s < nStates[n]; s++)
        {
            if(nodeBel[n+nNodes*s] > 1e-10)
                entropy1 += (nNbrs-1)*nodeBel[n+nNodes*s]*log(nodeBel[n+nNodes*s]);
            
            energy1 -= nodeBel[n+nNodes*s]*log(nodePot[n+nNodes*s]);
        }
    }
    for(e = 0; e < nEdges; e++)
    {
        n1 = edgeEnds[e];
        n2 = edgeEnds[e+nEdges];
        
        for(s1 = 0; s1 < nStates[n1];s1++)
        {
            for(s2 = 0; s2 < nStates[n2]; s2++)
            {
                if(edgeBel[s1+maxState*(s2+maxState*e)] > 1e-10)
                {
                    entropy2 -= edgeBel[s1+maxState*(s2+maxState*e)]*log(edgeBel[s1+maxState*(s2+maxState*e)]);
                }
                energy2 -= edgeBel[s1+maxState*(s2+maxState*e)]*log(edgePot[s1+maxState*(s2+maxState*e)]);
            }
        }
    }
    logZ[0] = -energy1-energy2+entropy1+entropy2;
    
    
    
    
   /* Free memory */
    mxFree(prodMsgs);
    mxFree(oldMsgs);
    mxFree(newMsgs);
    mxFree(tmp);
}
