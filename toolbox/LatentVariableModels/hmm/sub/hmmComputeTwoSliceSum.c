#include "mex.h"
/*
 * Compute the sum of the two-slice distributions over hidden states.
 * Let K be the number of hidden states, and T be the number of time steps.
 * Let S(t) denote the hidden state at time t, and y(t) be the 
 * (not ncessarily scalar) observation at time t. 
 *
 * INPUTS:
 *
 * alpha, and beta are computed using e.g. forwards backwards,
 * A is the state transition matrix, whose *rows* sum to one,
 * and B is the soft evidence. 
 *
 * alpha(j, t)      = p( S(t) = j  | y(1:t)    )   (KxT) 
 * beta (j, t) propto p( y(t+1:T)  | S(t)   = j)   (KxT)
 * A    (i, j)      = p( S(t) = j  | S(t-1) = i)   (KxK) 
 * B    (j, t)      = p( y(t)      | S(t)   = j)   (KxT)
 *
 * OUTPUT:
 * 
 * output(i, j) = sum_t=2:T p(S(t) = i, S(t+1) = j | y(1:T)), t=2:T   (KxK)
 *
 * The output constitutes the expected sufficient statistics for the 
 * transition matrix, for a given observation sequence. 
 *
 * Here is the equivalent MATLAB code: 
 *****************************************************************
 * function xiSummed = hmmComputeTwoSliceSum(alpha, beta, A, B)
 * [K, T] = size(B);
 * xiSummed = zeros(K, K);
 * for t = T-1:-1:1
 *     b        = beta(:, t+1) .* B(:, t+1);
 *     xit      = A .* (alpha(:, t) * b');
 *     xiSummed = xiSummed + xit./sum(xit(:));
 * end
 *****************************************************************
 *
 * Matt Dunham, August 19, 2010
 */
void mexFunction(int nlhs, mxArray * plhs[], int nrhs, const mxArray * prhs[])
{
    int t, i, j;                       /* loop indices */
    int K, T;                          /* sizes */
    int ndx;   
    double * alpha, * beta, * A, * B;  /* inputs */
    double * output;                   
    double * b, * xit;                 /* temporary storage */
    double xitSum;   
    
    if (nrhs != 4 || nlhs != 1){
        mexErrMsgTxt("requires 4 inputs, and 1 output");
    }
    for (i = 0; i < nrhs; ++i){
        if (mxIsComplex(prhs[i]) || !mxIsDouble(prhs[i]) ){
             mexErrMsgTxt("inputs must all be real, double matrices");
        }
    }
    K = mxGetM(prhs[0]);         
    T = mxGetN(prhs[0]); 
    if (mxGetM(prhs[1]) != K || mxGetN(prhs[1]) != T){
         mexErrMsgTxt("input sizes do not all agree");
    }
    if (mxGetM(prhs[2]) != K || mxGetN(prhs[2]) != K){
         mexErrMsgTxt("input sizes do not all agree");
    }
    if (mxGetM(prhs[3]) != K || mxGetN(prhs[3]) != T){
         mexErrMsgTxt("input sizes do not all agree");
    }
    alpha   = mxGetPr(prhs[0]); 
    beta    = mxGetPr(prhs[1]); 
    A       = mxGetPr(prhs[2]);        
    B       = mxGetPr(prhs[3]);        
    plhs[0] = mxCreateDoubleMatrix(K, K, mxREAL);
    output  = mxGetPr(plhs[0]); 
    b       = mxMalloc(K*sizeof(double));
    xit     = mxMalloc(K*K*sizeof(double));
    for (t = T-2; t >= 0; --t)  {
        for (j = 0; j < K; ++j) {
            ndx  = j + K*(t+1); 
            b[j] = beta[ndx] * B[ndx]; 
        }
        xitSum = 0;
        for(i=0; i < K; ++i) {    
	       for(j = 0; j < K; ++j) {
                ndx      = i + j*K;
                xit[ndx] = A[ndx] * alpha[i + K*t] * b[j];
                xitSum  += xit[ndx];
           }
        }
        for(i=0; i<K ; ++i) {
            for(j = 0 ; j < K ; ++j) {
                ndx          = i + j*K; 
                output[ndx] += xit[ndx] / xitSum;      
            }
        }
    }
    mxFree(b);
    mxFree(xit); 
    return;  
}
