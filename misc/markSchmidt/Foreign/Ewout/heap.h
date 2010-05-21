/* $Id: heap.h 800 2008-02-26 22:32:04Z mpf $ */

#ifndef __HEAP_H__
#define __HEAP_H__

#define swap_double(a,b) { double c; c = (a); (a) = (b); (b) = c; }

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
void heap_sift( int root, int lastChild, double x[] );


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
void heap_sift_2( int root, int lastChild, double x[], double y[] );


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
int heap_del_max(int numElems, double x[]);


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
int heap_del_max_2( int numElems, double x[], double y[] );


/*!
  \brief  Build a heap by adding one element at a time.
  
  \param[in]      n   The length of x and ix.
  \param[in,out]  x   The array to be heapified.

*/
void heap_build( int n, double x[] );


/*!
  \brief  Build a heap by adding one element at a time.
  
  \param[in]      n   The length of x and ix.
  \param[in,out]  x   The array to be heapified.
  \param[in,out]  y   The array to be reordered in sync. with x.

*/
void heap_build_2( int n, double x[], double y[] );


#endif
