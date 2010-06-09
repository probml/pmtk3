/* oneProjectorCore.c
   $Id: oneProjectorCore.c 800 2008-02-26 22:32:04Z mpf $

   ----------------------------------------------------------------------
   This file is part of SPGL1 (Spectral Projected Gradient for L1).

   Copyright (C) 2007 Ewout van den Berg and Michael P. Friedlander,
   Department of Computer Science, University of British Columbia, Canada.
   All rights reserved. E-mail: <{ewout78,mpf}@cs.ubc.ca>.

   SPGL1 is free software; you can redistribute it and/or modify it
   under the terms of the GNU Lesser General Public License as
   published by the Free Software Foundation; either version 2.1 of the
   License, or (at your option) any later version.

   SPGL1 is distributed in the hope that it will be useful, but WITHOUT
   ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
   or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU Lesser General
   Public License for more details.

   You should have received a copy of the GNU Lesser General Public
   License along with SPGL1; if not, write to the Free Software
   Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301
   USA
   ----------------------------------------------------------------------
*/

#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <float.h>     /* provides DBL_EPSILON */
#include <sys/types.h>

#include "oneProjectorCore.h"
#include "heap.h"


/* ----------------------------------------------------------------------- */
int projectI(double xPtr[], double bPtr[], double tau, int n)
/* ----------------------------------------------------------------------- */
{  int
       i, j;
   double
       b,          /* Current element of vector b */
       csb,        /* Cumulative sum of b */
       alpha = 0,
       soft  = 0;  /* Soft thresholding value */

   /* The vector xPtr[] is initialized to bPtr[] prior to the function call */

   /* Check if tau is essentially zero.  Exit with x = 0. */
   if (tau < DBL_EPSILON) {
       for (i = 0; i < n; i++) xPtr[i] = 0;
       return 0;
   }

   /* Check if ||b||_1 <= lambda.  Exit with x = b. */
   for (csb = 0, i = 0; i < n; i++) csb += bPtr[i];
   if (csb <= tau)
       return 0;

   /* Set up the heap */
   heap_build(n, xPtr);

   /* Initialise csb with -tau so we don't have to subtract this at every iteration */
   csb = -tau;

   /* Determine threshold value `soft' */
   for (i = n, j = 0; j < n; soft = alpha)
   {  
      b = xPtr[0];       /* Get current maximum heap element         */
      j ++;              /* Give compiler some room for optimization */
      csb += b;          /* Update the cumulative sum of b           */

      /* Move heap to next maximum value */
      i = heap_del_max(i, xPtr);

      /* Compute the required step to satisfy the tau constraint */
      alpha  = csb / j;

      /* We are done as soon as the constraint can be satisfied    */
      /* without exceeding the current minimum value in `vector' b */
      if (alpha >= b)
          break;
   }

   /* Set the solution by applying soft-thresholding with `soft' */
   for (i = 0; i < n; i++)
   {  b = bPtr[i];
      if (b <= soft)
           xPtr[i] = 0;
      else xPtr[i] = b - soft; 
   }

   return j;
}


/* ----------------------------------------------------------------------- */
int projectD(double xPtr[], double bPtr[], double dPtr[], double dOrg[], double tau, int n)
/* ----------------------------------------------------------------------- */
{  int
       i, j;
   double
       csdb,        /* Cumulative sum of d.*b          */
       csd2,        /* Cumulative sum of d.^2          */
       b,           /* Current element of vector b     */
       d,           /* Current element of vector d     */
       bd,          /* Current element of vector b / d */
       alpha  = 0,
       soft   = 0;

   /* Check if tau is essentially zero.  Exit with x = 0. */
   if (tau < DBL_EPSILON)
   {   for (i = 0; i < n; i++) xPtr[i] = 0;
       return 0;
   }

   /* Preliminary check on trivial solution x = b (meanwhile, scale x) */
   for (csdb = 0, i = 0; i < n; i++)
   {  d = dPtr[i];
      b = xPtr[i];
      csdb += (d * b);
      xPtr[i] = b / d;
   }

   if (csdb <= tau)
   {  
       /* Reset the entries of x to b */
      memcpy((void *)xPtr, (void *)bPtr, n * sizeof(double));
      return 0;
   }

   /* Set up the heap (we have to sort on b./d) */
   heap_build_2(n, xPtr, dPtr);

   /* Initialise csbd with -tau so we don't have to subtract this at every iteration */
   csdb = -tau;
   csd2 =  0;

   /* Determine the threshold level `soft' */
   for (i = n, j = 0; j < n; soft = alpha)
   {
      bd    = xPtr[0];        /* Get current maximum b / d                */
      j    ++;                /* Give compiler some room for optimization */
      d     = dPtr[0];        /* Get current value of d                   */
      d    *= d;              /* Compute d squared                        */
      csd2 += d;              /* Update the cumulative sum of d.*d        */
      csdb += bd * d;         /* Update the cumulative sum of d.*b        */

      /* Move heap to next maximum value */
      i = heap_del_max_2(i, xPtr, dPtr);

      /* Compute the required step to satisfy the lambda constraint */
      alpha  = csdb / csd2;

      /* We are done as soon as the constraint can be satisfied */
      /* without exceeding the current minimum value of b / d   */
      if (alpha >= bd) break;
   }

   /* Set the solution */
   for (i = 0; i < n; i++)
   {  b     = bPtr[i];
      alpha = dOrg[i] * soft; /* Use the original values of d here */
      if (b <= alpha)
           xPtr[i] = 0;
      else xPtr[i] = b - alpha;
   }

   return j;
}
