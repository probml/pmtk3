/* projectBlockL1.c
   $Id$

   W = projectBlockL1(W, nIndices, lambda)

   ASSUMPTION: nIndices is a column vector
   WARNING: Transformation is done in-place!
   WARNING: No parameter checking is done!
*/

#include <string.h>
#include <stdlib.h>
#include <math.h>
#include "oneProjectorCore.h"
#include "mex.h"


/* ----------------------------------------------------------------------- */
void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
/* ----------------------------------------------------------------------- */
{  mxArray       *matrixW;
   double        *matrixWPtr;
   const mxArray *nIndices;
   double        *nIndicesPtr;
   const mxArray *lambda;
   double        *lambdaPtr;

   double        *src, *dst, tau, v, w;

   int            i,j,m,n,p,q,r,s,offsetM,offsetN;
   unsigned int   dims[2];
   

   /* Extract parameters */
   matrixW     = (mxArray *)prhs[0];
   matrixWPtr  = mxGetPr(matrixW);
   nIndices    = prhs[1];
   nIndicesPtr = mxGetPr(nIndices);
   lambda      = prhs[2];
   lambdaPtr   = mxGetPr(lambda);

   /* Process non-diagonal blocks */
   m = mxGetM(nIndices);
   n = mxGetM(nIndices);
   s = mxGetM(matrixW);     /* Stride: number of rows in W */
   offsetN = 0;
   for (j = 0; j < n; j++)
   {   offsetM = 0;
       for(i = 0; i < m; i++)
       {   /* Set indicex */
           src  = matrixWPtr + offsetM + offsetN * s;
           tau  = lambdaPtr[i+j*m];

           /* Deal with diagonal blocks */
           if (i == j)
           {
              r = nIndicesPtr[i]; /* Number of rows in current block */
              for (q = 0; q < nIndicesPtr[j]; q++)
              {  for (p = 0; p < r; p++)
                 {  v = *src;
                    if (v < 0)
                    {  if (v < -tau) *src = -tau;
                    }
                    else
                    {  if (v > tau) *src = tau;
                    }

                    src ++;
                 }
                 src = src + s - r;
              }
           }
           else if (i > j)
           { 
              /* Number of rows in current block */
              r = nIndicesPtr[i];

              /* Compute norm */
              v = 0;
              for (q = 0; q < nIndicesPtr[j]; q++)
              {  for (p = 0; p < r; p++)
                 {  w = *src;
                    v = v + w * w;                    
                    src ++;
                 }
                 src = src + s - r;
              }
              v = sqrt(v);

              /* Scale entries if needed */
              src = matrixWPtr + offsetM + offsetN * s;
              if (v > tau)
              {  v = tau / v;
                 for (q = 0; q < nIndicesPtr[j]; q++)
                 {  for (p = 0; p < r; p++)
                    {  *src *= v;
                       src ++;
                    }
                    src = src + s - r;
                 }
              }
           }
           else /* Copy result from symmetric block */
           {   
              /* Number of rows in current block */
              r = nIndicesPtr[i];

              /* Copy block in transpose*/
              src = matrixWPtr + offsetM * s + offsetN;
              dst = matrixWPtr + offsetM + offsetN * s;
              for (q = 0; q < nIndicesPtr[j]; q++)
              {  for (p = 0; p < r; p++)
                 {  *dst = *src;
                    dst ++; src += s;
                 }
                 dst = dst + s - r;
                 src = src + 1 - r*s;
              }
           }

           offsetM = offsetM + nIndicesPtr[i];
       }
       offsetN = offsetN + nIndicesPtr[j];
   }

   return ;
}

