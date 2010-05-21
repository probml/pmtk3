#include <math.h>
#include "mex.h"
#include "UGM_common.h"
 
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
    int i, n, n1, n2, p, e, s, s1, s2, sInd, edgeInd, 
    nInstances,nNodeFeatures,nEdgeFeatures,maxState,nNodes,nEdges,
    *y, *edgeEnds, *V, *E, *nStates, tieNodes,tieEdges, ising, sizF[2], 
    y_neigh, neigh;
    
    double *f, *gw, *gv, *w, *v, *X, *Xedge, *nodePot, *edgePot,
    *pot, Z, observed, expected;
    
    /* Input */
    gw = mxGetPr(prhs[0]);
    gv = mxGetPr(prhs[1]);
    w = mxGetPr(prhs[2]);
    v = mxGetPr(prhs[3]);
    X = mxGetPr(prhs[4]);
    Xedge = mxGetPr(prhs[5]);
    y = mxGetPr(prhs[6]);
    nodePot = mxGetPr(prhs[7]);
    edgePot = mxGetPr(prhs[8]);
    edgeEnds = mxGetPr(prhs[9]);
    V = mxGetPr(prhs[10]);
    E = mxGetPr(prhs[11]);
    nStates = mxGetPr(prhs[12]);
    tieNodes = mxGetScalar(prhs[13]);
    tieEdges = mxGetScalar(prhs[14]);
    ising = mxGetScalar(prhs[15]);
    
    /* Compute Sizes */
    nInstances = mxGetDimensions(prhs[4])[0];
    nNodeFeatures = mxGetDimensions(prhs[4])[1];
    nNodes = mxGetDimensions(prhs[4])[2];
    nEdgeFeatures = mxGetDimensions(prhs[5])[1];
    nEdges = mxGetDimensions(prhs[9])[0];
    maxState = getMaxState(nStates,nNodes);
    decrementEdgeEnds(edgeEnds,nEdges);
    for(i = 0; i < nInstances; i++)
    {
        for(n = 0; n < nNodes; n++)
        {
            y[i + nInstances*n]--;
        }
    }
    for(n = 0; n <= nNodes; n++)
    {
        V[n]--;
    }
    for(e = 0; e < nEdges*2; e++)
    {
        E[e]--;
    }
    
    /* Allocate */
    pot = mxCalloc(maxState,sizeof(double));
    
    /* Output */
    sizF[0] = 1;
    sizF[1] = 1;
    plhs[0] = mxCreateNumericArray(2,sizF,mxDOUBLE_CLASS,mxREAL);
    f = mxGetPr(plhs[0]);
    *f = 0;
    
    for(i = 0; i < nInstances; i++)
    {
        for(n = 0; n < nNodes; n++)
        {
         
            /* Compute NodePot for all States */
            for(s = 0; s < nStates[n]; s++)
            {
                pot[s] = nodePot[n + nNodes*(s + maxState*i)];
            }

            /* Add EdgePot for each state with neighbors fixed */
            for(edgeInd = V[n]; edgeInd < V[n+1]; edgeInd++)
            {
                e = E[edgeInd];
                n1 = edgeEnds[e];
                n2 = edgeEnds[e+nEdges];
                if(n == edgeEnds[e])
                {
                    for(s = 0; s < nStates[n]; s++)
                    {
                        pot[s] *= edgePot[s + maxState*(y[i + nInstances*n2] + maxState*(e + nEdges*i))];
                    }
                }
                else
                {
                    for(s = 0; s < nStates[n]; s++)
                    {
                        pot[s] *= edgePot[y[i + nInstances*n1] + maxState*(s + maxState*(e + nEdges*i))];
                    }
                }
            }
           
            /* Update Objective */
            Z = 0;
            for(s = 0; s < nStates[n]; s++)
            {
                Z += pot[s];
            }
            *f = *f - log(pot[y[i + nInstances*n]]) + log(Z);
            
            /* Node Beliefs */
            for(s = 0; s < nStates[n]; s++)
            {
                pot[s] = pot[s]/Z;
            }
            
            /* Update Gradient of Node Weights */
            for(s = 0; s < nStates[n]-1; s++)
            {
                if(s == y[i + nInstances*n])
                {
                    observed = 1;
                }
                else
                {
                    observed = 0;
                }
                expected = pot[s];
                
                for(p = 0; p < nNodeFeatures; p++)
                {
                    if (tieNodes)
                    {
                        gw[p + nNodeFeatures*s] -= (observed - expected)*X[i+nInstances*(p+nNodeFeatures*n)];
                    }
                    else
                    {
                        gw[p + nNodeFeatures*(s + (maxState-1)*n)] -= (observed - expected)*X[i+nInstances*(p+nNodeFeatures*n)];
                    }
                }
            }
            
            
            /* Update Gradient of Edge Weights */
            for(edgeInd = V[n]; edgeInd < V[n+1]; edgeInd++)
            {
                e = E[edgeInd];
                n1 = edgeEnds[e];
                n2 = edgeEnds[e+nEdges];
                
                if (ising == 2) {
                    if(y[i + nInstances*n1] == y[i + nInstances*n2])
                    {
                        observed = 1;
                    }
                    else
                    {
                        observed = 0;
                    }
                    
                    if(n == n1)
                    {
                        y_neigh = y[i + nInstances*n2];
                    }
                    else
                    {
                        y_neigh = y[i + nInstances*n1];
                    }
                    
                    if(y_neigh < nStates[n])
                    {
                        expected = pot[y_neigh];
                    }
                    else
                    {
                        expected = 0;
                    }
                    
                    for (p = 0; p < nEdgeFeatures; p++)
                    {
                        if (tieEdges)
                        {
                            gv[p+nEdgeFeatures*y_neigh] -= (observed-expected)*Xedge[i + nInstances*(p + nEdgeFeatures*e)];
                        }
                        else
                        {
                            gv[p+nEdgeFeatures*(y_neigh+maxState*e)] -= (observed-expected)*Xedge[i + nInstances*(p + nEdgeFeatures*e)];
                        }
                    }
                }
                else if (ising)
                {
                    if(y[i + nInstances*n1] == y[i + nInstances*n2])
                    {
                        observed = 1;
                    }
                    else
                    {
                        observed = 0;
                    }
                    
                    if(n == n1)
                    {
                        y_neigh = y[i + nInstances*n2];
                    }
                    else
                    {
                        y_neigh = y[i + nInstances*n1];
                    }
                    
                    if(y_neigh < nStates[n])
                    {
                        expected = pot[y_neigh];
                    }
                    else
                    {
                        expected = 0;
                    }
                    
                    for (p = 0; p < nEdgeFeatures; p++)
                    {
                        if (tieEdges)
                        {
                            gv[p] -= (observed-expected)*Xedge[i + nInstances*(p + nEdgeFeatures*e)];
                        }
                        else
                        {
                            gv[p+nEdgeFeatures*e] -= (observed-expected)*Xedge[i + nInstances*(p + nEdgeFeatures*e)];
                        }
                    }
                    
                }
                else /* (~ising) */
                {
                    for(s = 0; s < nStates[n]; s++)
                    {
                        if (n == n1)
                        {
                            neigh = n2;
                        }
                        else
                        {
                            neigh = n1;
                        }
                        
                        if(s == nStates[n]-1 && y[i + nInstances*neigh] == nStates[neigh]-1)
                        {
                            continue;
                        }
                        
                        if (s == y[i + nInstances*n])
                        {
                            observed = 1;
                        }
                        else
                        {
                            observed = 0;
                        }
                        expected = pot[s];
                        
                        if (n == n1)
                        {
                            s1 = s;
                            s2 = y[i + nInstances*neigh];
                        }
                        else
                        {
                            s1 = y[i + nInstances*neigh];
                            s2 = s;
                        }
                        sInd = s1+s2*maxState;
                        
                        for(p = 0; p < nEdgeFeatures; p++)
                        {
                            if (tieEdges)
                            {
                                gv[p + nEdgeFeatures*sInd] -= (observed-expected)*Xedge[i + nInstances*(p + nEdgeFeatures*e)];
                            }
                            else
                            {
                                gv[p + nEdgeFeatures*(sInd + (maxState*maxState-1)*e)] -= (observed-expected)*Xedge[i + nInstances*(p + nEdgeFeatures*e)];
                            }
                        }
                    }
                }
                
                
            }
        }
    }
    
    mxFree(pot);
}