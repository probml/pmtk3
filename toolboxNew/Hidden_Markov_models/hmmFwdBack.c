#include <math.h>
#include "mex.h"
#include <string.h>

double normalizeInPlace(double *, unsigned int);
void multiplyInPlace(double *, double *, double *, unsigned int);
void multiplyMatrixInPlace(double *, double *, double *, unsigned int);
void transposeSquareInPlace(double *, double *, unsigned int);
void outerProductUVInPlace(double *, double *, double *, unsigned int);
void componentVectorMultiplyInPlace(double *, double *, double *, unsigned int);

   /*
     To test in Matlab with the usual fwd_back that has 4 outputs :
        init_states = rand(4,1);
	trans = rand(4,4);
	obslik = rand(4,10);
	[E1,E2,E3,E4] = fwd_backC(init_states, trans, obslik);
	[F1,F2,F3,F4] = fwd_back(init_states, trans, obslik);
	max(max(abs(E1 - F1)))
	max(max(abs(E2 - F2)))
	max(max(abs(E3 - F3)))
	max(max(abs(E4 - F4)))

    or this with the fwd_back version that returns eta also :
        init_states = rand(4,1);
	trans = rand(4,4);
	obslik = rand(4,10);
        [F1,F2,F3,F4,F5] = fwd_backC(init_states, trans, obslik);
	[E1,E2,E3,E4,E5] = fwd_back(init_states, trans, obslik);
	max(max(abs(E1 - F1)))
	max(max(abs(E2 - F2)))
	max(max(abs(E3 - F3)))
	max(abs(E4(:) - F4(:)))
	max(max(abs(E5 - F5)))

    */

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double * init_state_distrib, * transmat, * obslik;
    int K, T, tmp;
    
    /* the tranposed version of transmat*/
    double * transmatT;

    double * scale, * alpha, * beta, * gamma;
    int t,d;
    double loglik = 0;
    
    /* special care for eta since it has 3 dimensions and needs to be written
       with mxCreateNumericArray instead of mxCreateDoubleMatrix */
    double * eta;
    int eta_ndim = 3;
    int * eta_dims = mxMalloc(eta_ndim*sizeof(int));

    double *m, *b, *squareSpace; /* temporary quantities in the algorithm */
    double *outputToolPtr;

    if (nrhs!=3 || !(nlhs==4 || nlhs==5))
	mexErrMsgTxt("fwd_backC requires 3 inputs and 4-5 outputs");

    init_state_distrib=mxGetPr(prhs[0]);
    transmat=mxGetPr(prhs[1]);
    obslik=mxGetPr(prhs[2]);

    /* Assuming this will allow me to take row or colums as arguments. */
    K = mxGetN(prhs[0]) * mxGetM(prhs[0]);

    transmatT = mxMalloc(K*K*sizeof(double));
    transposeSquareInPlace(transmatT, transmat, K);

    tmp = mxGetN(prhs[1]);
    if (tmp != K)
	mexErrMsgTxt("The transition matrix must be of size KxK.");
    tmp = mxGetM(prhs[1]);
    if (tmp != K)
	mexErrMsgTxt("The transition matrix must be of size KxK.");

    obslik = mxGetPr(prhs[2]);
    /* I might have switched M and N.*/
    T = mxGetN(prhs[2]);
    tmp = mxGetM(prhs[1]);
    if (tmp != K)
	mexErrMsgTxt("The obslik must have K rows.");

    scale = mxMalloc(T*sizeof(double));

    alpha = mxMalloc(K*T*sizeof(double));
    beta = mxMalloc(K*T*sizeof(double));
    gamma = mxMalloc(K*T*sizeof(double));

    /********* Forward. ********/

    t = 0;
    multiplyInPlace(alpha + t*K, init_state_distrib, obslik + t*K, K);
    scale[t] = normalizeInPlace(alpha + t*K, K);
    
    m = mxMalloc(K*sizeof(double));

    for(t=1;t<T;++t){
	multiplyMatrixInPlace(m, transmatT, alpha + (t-1)*K, K);
	multiplyInPlace(alpha + t*K, m, obslik + t*K, K);
	scale[t] = normalizeInPlace(alpha + t*K, K);
    }

    loglik = 0;
    for(t=0;t<T;++t)
	loglik += log(scale[t]);

    /********* Backward. ********/

    
    t = T-1;
    /* I don't think we need to initialize beta to all zeros. */
    for(d=0;d<K;++d) {
	beta[d + t*K] = 1;
	gamma[d + t*K] = alpha[d + t*K];
    }
    
    b = mxMalloc(K*sizeof(double));/*mxCreateDoubleMatrix(K,1,mxREAL);*/
    eta = mxMalloc(K*K*T*sizeof(double));
    squareSpace = mxMalloc(K*K*sizeof(double));

    /* Put the last slice of eta as zeros, to be compatible with Sohrab and Gavin's code.
       There are no values to put there anyways. This means that you can't normalise the
       last matrix in eta, but it shouldn't be used. Note the d<K*K range.
     */
    for(d=0;d<(K*K);++d) {
	/*mexPrintf("setting *(eta + %d) = 0 \n", d+t*K*K);*/
	*(eta + d + t*K*K) = 0;/*(double)7.0f;*/
    }

    /* We have to remember that the 1:T range in Matlab is 0:(T-1) in C. */
    for(t=(T-2);t>=0;--t) {
	
	/* setting beta */
	    multiplyInPlace(b, beta + (t+1)*K, obslik + (t+1)*K, K);
	    /* Using "m" again instead of defining a new temporary variable.
	       We using a lot of lines to say
	           beta(:,t) = normalize(transmat * b);
	    */
	    multiplyMatrixInPlace(m, transmat, b, K);
	    normalizeInPlace(m,K);
	    for(d=0;d<K;++d) { beta[d + t*K] = m[d]; }
	    /* using "m" again as valueholder */
	
	/* setting eta, whether we want it or not in the output */
	    outerProductUVInPlace(squareSpace, alpha + t*K, b, K);
	    componentVectorMultiplyInPlace(eta + t*K*K, transmat, squareSpace, K*K);
	    normalizeInPlace(eta + t*K*K, K*K);
	
	/* setting gamma */

	    multiplyInPlace(m,alpha + t*K, beta + t*K, K);
	    normalizeInPlace(m,K);
	    for(d=0;d<K;++d) { gamma[d + t*K] = m[d]; }
    }


    
    plhs[0] = mxCreateDoubleMatrix(K,T,mxREAL);
    outputToolPtr = mxGetPr(plhs[0]);
    memcpy(outputToolPtr, gamma, K*T*sizeof(double));

    plhs[1] = mxCreateDoubleMatrix(K,T,mxREAL);
    outputToolPtr = mxGetPr(plhs[1]);
    memcpy(outputToolPtr, alpha, K*T*sizeof(double));

    plhs[2] = mxCreateDoubleMatrix(K,T,mxREAL);
    outputToolPtr = mxGetPr(plhs[2]);
    memcpy(outputToolPtr, beta, K*T*sizeof(double));

    /* This handles the two possible cases for outputs, based on the number of outputs.
       It's either
          [gamma,alpha,beta,eta,loglik]
       or
          [gamma,alpha,beta,loglik].
    */
    if (nlhs == 4) {
	plhs[3] = mxCreateDoubleMatrix(1,1,mxREAL);
	outputToolPtr = mxGetPr(plhs[3]);
	outputToolPtr[0] = loglik;
    } else if (nlhs == 5) {
	eta_dims[0] = K;
	eta_dims[1] = K;
	eta_dims[2] = T;
	plhs[3] = mxCreateNumericArray(eta_ndim, eta_dims, mxDOUBLE_CLASS, mxREAL);
	outputToolPtr = mxGetPr(plhs[3]);
	memcpy(outputToolPtr, eta, K*K*T*sizeof(double));


	plhs[4] = mxCreateDoubleMatrix(1,1,mxREAL);
	outputToolPtr = mxGetPr(plhs[4]);
	outputToolPtr[0] = loglik;

    }

    
    mxFree(b); mxFree(m); mxFree(squareSpace);
    mxFree(scale); mxFree(transmatT);
    mxFree(alpha); mxFree(beta); mxFree(gamma); mxFree(eta); mxFree(eta_dims);

    return;
}

/* And returns the normalization constant used.
   I'm assuming that all I'll want to do is to normalize columns
   so I don't need to include a stride variable.
*/
double normalizeInPlace(double * A, unsigned int N) {
    unsigned int n;
    double sum = 0;

    for(n=0;n<N;++n) {
	sum += A[n];
	if (A[n] < 0) {
	    mexErrMsgTxt("We don't want to normalize if A contains a negative value. This is a logical error.");
	}
    }

    if (sum > 0){
	for(n=0;n<N;++n)
	    A[n] /= sum;
    }
    return sum;
}

void multiplyInPlace(double * result, double * u, double * v, unsigned int K) {
    unsigned int n;

    for(n=0;n<K;++n)
	result[n] = u[n] * v[n];

    return;
}

void multiplyMatrixInPlace(double * result, double * trans, double * v, unsigned int K) {

    unsigned int i,d;

    for(d=0;d<K;++d) {
	result[d] = 0;
	for (i=0;i<K;++i){
	    result[d] += trans[d + i*K] * v[i];
	}
    }
    return;
}

void transposeSquareInPlace(double * out, double * in, unsigned int K) {

    unsigned int i,j;

    for(i=0;i<K;++i){
	for(j=0;j<K;++j){
	    out[j+i*K] = in[i+j*K];
	}
    }
    return;
}

void outerProductUVInPlace(double * Out, double * u, double * v, unsigned int K) {
    unsigned int i,j;

    for(i=0;i<K;++i){
	for(j=0;j<K;++j){
	    Out[i + j*K] = u[i] * v[j];
	}
    }
    return;
}

/* this works for matrices also if you just set the length "L" to be the right value,
   often K*K, instead of just K in the case of vectors
*/
void componentVectorMultiplyInPlace(double * Out, double * u, double * v, unsigned int L) {
    unsigned int i;

    for(i=0;i<L;++i)
	Out[i] = u[i] * v[i];

    return;
}
