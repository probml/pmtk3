#include <math.h>
#include "mex.h"
#include "UGM_common.h"


void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
   /* Variables */
   int n, s,s1,s2,n1,n2,e, yInd,
   nNodes, nEdges, maxState, sizeEdgeBel[3], sizeLogZ[2],
   *y,
   *edgeEnds, *nStates;
   
   double pot,Z,
   *nodePot, *edgePot, *nodeBel, *edgeBel, *logZ;
   
   /* Input */
   
   nodePot = mxGetPr(prhs[0]);
   edgePot = mxGetPr(prhs[1]);
   edgeEnds = mxGetPr(prhs[2]);
   nStates = mxGetPr(prhs[3]);
   
   /* Compute Sizes */
   
   nNodes = mxGetDimensions(prhs[0])[0];
   maxState = mxGetDimensions(prhs[0])[1];
   nEdges = mxGetDimensions(prhs[2])[0];
   decrementEdgeEnds(edgeEnds,nEdges);
   
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
   y = mxCalloc(nNodes,sizeof(int));
   Z = 0;
   
   while(1)
   {
      pot = 1;
      
   /* Node */
      for(n = 0; n < nNodes; n++)
      {
         pot *= nodePot[n + nNodes*y[n]];
      }
      
   /* Edges */
      for(e = 0; e < nEdges; e++)
      {
         n1 = edgeEnds[e];
         n2 = edgeEnds[e+nEdges];
         pot *= edgePot[y[n1] + maxState*(y[n2] + maxState*e)];
      }
      
   /* Update nodeBel */
      for(n = 0; n < nNodes; n++)
      {
         nodeBel[n + nNodes*y[n]] += pot;
      }
      
   /* Update edgeBel */
      for (e = 0; e < nEdges; e++)
      {
         n1 = edgeEnds[e];
         n2 = edgeEnds[e+nEdges];
         edgeBel[y[n1] + maxState*(y[n2] + maxState*e)] += pot;
      }
      
   /* Update Z */
      Z += pot;
      
   /* Go to next y */
      
      for(yInd = 0; yInd < nNodes; yInd++)
      {
         y[yInd] += 1;
         if(y[yInd] < nStates[yInd])
         {
          break;  
         }
         else
         {
            y[yInd] = 0;
         }
      }

   /* Stop when we are done all y combinations */
      if(yInd == nNodes)
      {
         break;
      }
   }
   
   /* Normalize by Z */
   for(n = 0; n < nNodes; n++)
   {
      for(s = 0; s < nStates[n];s++)
      {
         nodeBel[n + nNodes*s] /= Z;
      }
   }
   for(e = 0; e < nEdges; e++)
   {
      n1 = edgeEnds[e];
      n2 = edgeEnds[e+nEdges];
      for(s1 = 0; s1 < nStates[n1]; s1++)
      {
         for(s2 = 0; s2 < nStates[n2]; s2++)
         {
            edgeBel[s1 + maxState*(s2 + maxState*e)] /= Z;
         }
      }
   }
   *logZ = log(Z);
   
   /* Free memory */
   mxFree(y);
}
