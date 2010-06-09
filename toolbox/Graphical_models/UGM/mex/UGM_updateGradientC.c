#include <math.h>
#include "mex.h"
#include "UGM_common.h"
 
 
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
   
   int n, n1, n2, p, e, s, s1, s2,
   nNodeFeatures, nEdgeFeatures,  maxState, nNodes, nEdges,
   *edgeEnds, *nStates, tieNodes,tieEdges, ising;
   
   double temp, *gw, *gv, *X, *Xedge, *y, observed, expected,
   *nodeBel, *edgeBel;
   
   /* Input */
   
   gw = mxGetPr(prhs[0]);
   gv = mxGetPr(prhs[1]);
   X = mxGetPr(prhs[2]);
   Xedge = mxGetPr(prhs[3]);
   y = mxGetPr(prhs[4]);
   nodeBel = mxGetPr(prhs[5]);
   edgeBel = mxGetPr(prhs[6]);
   nStates = mxGetPr(prhs[7]);
   tieNodes = mxGetScalar(prhs[8]);
   tieEdges = mxGetScalar(prhs[9]);
   ising = mxGetScalar(prhs[10]);
   edgeEnds = mxGetPr(prhs[11]);
  
   
   
   /* Compute Sizes */
   nNodeFeatures = mxGetDimensions(prhs[2])[1];
   nNodes = mxGetDimensions(prhs[2])[2];
   nEdgeFeatures = mxGetDimensions(prhs[3])[1];
   nEdges = mxGetDimensions(prhs[11])[0];
   maxState = getMaxState(nStates,nNodes);
   decrementEdgeEnds(edgeEnds,nEdges);
   for(n = 0; n < nNodes; n++)
      y[n]--;
   
   
   
   /* Update gw */
   for(n = 0; n < nNodes; n++)
   {
      
      for(s = 0; s < nStates[n]-1; s++)
      {
         
         if (s == y[n])
         {
            observed = 1;
         }
         else
         {
            observed = 0;
         }
         expected = nodeBel[n + nNodes*s];
         
         for(p = 0; p < nNodeFeatures; p++)
         {
            if (tieNodes)
            {
               gw[p + nNodeFeatures*s] -= (observed - expected)*X[p+nNodeFeatures*n];
            }
            else
            {
               gw[p + nNodeFeatures*(s + (maxState-1)*n)] -= (observed - expected)*X[p+nNodeFeatures*n];
            }
         }
         
      }
   }
   
   /* Update gv */
   for(e = 0; e < nEdges; e++)
   {
      n1 = edgeEnds[e];
      n2 = edgeEnds[e+nEdges];
      
      if (ising == 2) 
      {
          for(s = 0; s < nStates[n1] && s < nStates[n2]; s++) 
          {
           if (y[n1] == s && y[n2] == s) 
           {
               observed = 1;
           }
           else
           {
               observed = 0;
           }
           expected = edgeBel[s + maxState*(s + maxState*e)];
           
           for (p = 0; p < nEdgeFeatures; p++) {
               if (tieEdges) {
                   gv[p+nEdgeFeatures*s] -= (observed-expected)*Xedge[p + nEdgeFeatures*e];
               }
               else {
                   gv[p+nEdgeFeatures*(s+maxState*e)] -= (observed-expected)*Xedge[p + nEdgeFeatures*e];
               }
           }

          }
      }
      else if (ising)
      {
         if (y[n1] == y[n2])
         {
            observed = 1;
         }
         else
         {
            observed = 0;
         }
         expected = 0;
         for (s = 0; s < maxState; s++)
         {
            expected += edgeBel[s + maxState*(s + maxState*e)];
         }
         
         for (p = 0; p < nEdgeFeatures; p++)
         {
            if (tieEdges)
            {
               gv[p] -= (observed-expected)*Xedge[p + nEdgeFeatures*e];
            }
            else
            {
               gv[p+nEdgeFeatures*e] -= (observed-expected)*Xedge[p + nEdgeFeatures*e];
            }
         }
      }
      else /* (~ising) */
      {
         for (s1 = 0; s1 < nStates[n1]; s1++)
         {
            for (s2 = 0; s2 < nStates[n2]; s2++)
            {
               if (s1 == nStates[n1]-1 && s2 == nStates[n2]-1)
               {
                  continue;
               }
               if (s1 == y[n1] && s2 == y[n2])
               {
                  observed = 1;
               }
               else
               {
                  observed = 0;
               }
               expected = edgeBel[s1 + maxState*(s2 + maxState*e)];
               s = s1+s2*maxState;
               
               for(p = 0; p < nEdgeFeatures; p++)
               {
                if (tieEdges)
                {
                   gv[p + nEdgeFeatures*s] -= (observed-expected)*Xedge[p + nEdgeFeatures*e];
                }
                else
                {
                   gv[p + nEdgeFeatures*(s + (maxState*maxState-1)*e)] -= (observed-expected)*Xedge[p + nEdgeFeatures*e];
                }
               }
            }
         }
      }
   }
}
