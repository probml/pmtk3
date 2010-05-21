/* heap.c
   $Id $

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

#include <assert.h>

#include "heap.h"


/* ======================================================================= */
/*                     H E L P E R   F U N C T I O N S                     */
/* ======================================================================= */


/*
  \brief Perform the "sift" operation for the heap-sort algorithm.

  A heap is a collection of items arranged in a binary tree.  Each
  child node is smaller than or equal to its parent.  If x[k] is the
  parent, than its children are x[2k+1] and x[2k+2].

  This routine promotes ("sifts up") children that are larger than
  their parents.  Thus, the largest element of the heap is the root node.

  \param[in]     root       The root index from which to start sifting.
  \param[in]     lastChild  The last child (largest node index) in the sift operation.
  \param[in,out] x          The array to be sifted.
*/
void heap_sift( int root, int lastChild, double x[] )
{
    int child;

    for (; (child = (root * 2) + 1) <= lastChild; root = child) {

	if (child < lastChild)
	    if ( x[child] < x[child+1] )
		child++;
	
	if ( x[child] <= x[root] )
	    break;

	swap_double(  x[root],  x[child] );
    }
}


/*!
  \brief Perform the "sift" operation for the heap-sort algorithm.

  A heap is a collection of items arranged in a binary tree.  Each
  child node is smaller than or equal to its parent.  If x[k] is the
  parent, than its children are x[2k+1] and x[2k+2].

  This routine promotes ("sifts up") children that are larger than
  their parents.  Thus, the largest element of the heap is the root node.

  Elements in y are associated with those in x and are reordered accordingly.

  \param[in]     root       The root index from which to start sifting.
  \param[in]     lastChild  The last child (largest node index) in the sift operation.
  \param[in,out] x          The array to be sifted.
  \param[in,out] y          The array to be sifted accordingly.
*/
void heap_sift_2( int root, int lastChild, double x[], double y[] )
{
    int child;

    for (; (child = (root * 2) + 1) <= lastChild; root = child) {

	if (child < lastChild)
	    if ( x[child] < x[child+1] )
		child++;
	
	if ( x[child] <= x[root] )
	    break;

	swap_double( x[root], x[child] );
        swap_double( y[root], y[child] );
    }
}


/*!
  \brief Discard the largest element and contract the heap.

  On entry, the numElems of the heap are stored in x[0],...,x[numElems-1],
  and the biggest element is x[0].  The following operations are performed:
    -# Swap the first and last elements of the heap
    -# Shorten the length of the heap by one.
    -# Restore the heap property to the contracted heap.
       This effectively makes x[0] the next largest element
       in the list.

  \param[in]     numElems   The number of elements in the current heap.
  \param[in,out] x          The array to be modified.

  \return  The number of elements in the heap after it has been contracted.
*/
int heap_del_max(int numElems, double x[])
{
    int lastChild = numElems - 1;

    assert(numElems > 0);

    /* Swap the largest element with the lastChild. */
    swap_double(x[0], x[lastChild]);

    /* Contract the heap size, thereby discarding the largest element. */
    lastChild--;
    
    /* Restore the heap property of the contracted heap. */
    heap_sift(0, lastChild, x);

    return numElems - 1;
}


/*!
  \brief Discard the largest element of x and contract the heaps.

  On entry, the numElems of the heap are stored in x[0],...,x[numElems-1],
  and the largest element is x[0].  The following operations are performed:
    -# Swap the first and last elements of both heaps
    -# Shorten the length of the heaps by one.
    -# Restore the heap property to the contracted heap x.
       This effectively makes x[0] the next largest element
       in the list.  

  \param[in]     numElems   The number of elements in the current heap.
  \param[in,out] x          The array to be modified.
  \param[in,out] y          The array to be modified accordingly

  \return  The number of elements in each heap after they have been contracted.
*/
int heap_del_max_2( int numElems, double x[], double y[] )
{
    int lastChild = numElems - 1;

    assert(numElems > 0);

    /* Swap the largest element with the lastChild. */
    swap_double( x[0], x[lastChild] );
    swap_double( y[0], y[lastChild] ); 

    /* Contract the heap size, thereby discarding the largest element. */
    lastChild--;
    
    /* Restore the heap property of the contracted heap. */
    heap_sift_2( 0, lastChild, x, y );

    return numElems - 1;
}


/*!
  
  \brief  Build a heap by adding one element at a time.
  
  \param[in]      n   The length of x and ix.
  \param[in,out]  x   The array to be heapified.

*/
void heap_build( int n, double x[] )
{    
    int i;

    for (i = n/2; i >= 0; i--) heap_sift( i, n-1, x );
}


/*!
  
  \brief  Build a heap by adding one element at a time.
  
  \param[in]      n   The length of x and ix.
  \param[in,out]  x   The array to be heapified.
  \param[in,out]  y   The array to be reordered in sync. with x.

*/
void heap_build_2( int n, double x[], double y[] )
{
    int i;

    for (i = n/2; i >= 0; i--) heap_sift_2( i, n-1, x, y );
}
