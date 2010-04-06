#include "mex.h"
#include <string.h>

void copyVector(double *, double *, unsigned int);
void addVectors(double *, double *, double *, unsigned int);
void setVectorToValue(double *, double, unsigned int);
void setVectorToValue_int(int *, int, unsigned int);
void maxVectorInPlace(double *, int *, double *, unsigned int);

void mexFunction(int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    double * prior, * transmat, * obslik;
    int K, T, tmp;

    double * delta, *changes;
    int changesCounter;
    int * psi, * path;
    int t,k,j;
    double loglik;

    double * d; /* buffer */

    double *outputToolPtr;

    if ( nrhs!=3 || nlhs!=3)
	mexErrMsgTxt("hmmViterbiC requires 3 inputs and 3 outputs");

    prior=mxGetPr(prhs[0]);
    transmat=mxGetPr(prhs[1]);
    obslik=mxGetPr(prhs[2]);

    /* Assuming this will allow me to take row or colums as arguments. */
    K = mxGetN(prhs[0]) * mxGetM(prhs[0]);

    /* mexPrintf("K = %d\n", K); */

    tmp = mxGetN(prhs[1]);
    if (tmp != K)
	mexErrMsgTxt("The transition matrix must be of size KxK.");
    tmp = mxGetM(prhs[1]);
    if (tmp != K)
	mexErrMsgTxt("The transition matrix must be of size KxK.");

    /* meaning that obslik is K-by-T, with the chain running along with horizontal */
    T = mxGetN(prhs[2]);
    tmp = mxGetM(prhs[1]);
    if (tmp != K)
	mexErrMsgTxt("The obslik must have K rows.");

    delta = mxMalloc(K*T*sizeof(double));
    psi = mxMalloc(K*T*sizeof(int));
    path = mxMalloc(T*sizeof(int));

    t = 0;
    addVectors(delta + t*K, prior, obslik + t*K, K);
    setVectorToValue_int(psi + t*K, 0, K);

    d = mxMalloc(K*sizeof(double));

    /* forward */
    for(t=1;t<T;++t) {
	for(j=0;j<K;++j) {
  	    addVectors(d, delta + (t-1)*K, transmat + j*K, K);
	    maxVectorInPlace(delta + j + t*K, psi + j + t*K, d, K);
	    delta[j+t*K] += obslik[j+t*K];
	}
    }


    /* backward */
    t = T-1;
    maxVectorInPlace(d, path + t, delta + t*K, K); /* using the first value of d to store junk */
    loglik = d[0];

    for(t=T-2;t>=0;--t) {
	path[t] = psi[path[t+1] + (t+1)*K];
	/*mexPrintf("Setting path[%d]=%d\n", t, path[t]); */
    }

    changes = mxMalloc(4*T*sizeof(double));
    changesCounter = 0;
    changes[changesCounter + 0*T] = 0;
    changes[changesCounter + 1*T] = 0; /* overwritten */
    changes[changesCounter + 2*T] = path[0];
    changes[changesCounter + 3*T] = 0;
    changesCounter = 1;

    for(t=1;t<T;++t) {
	if (path[t] != path[t-1]) {
	    changes[changesCounter + 0*T] = t;
	    changes[(changesCounter-1) + 1*T] = t-1;
	    changes[changesCounter + 2*T] = path[t];
	    changes[changesCounter + 3*T] = 0; /* that computeSegmentBayesFactor */
	    changesCounter++;
	}
    }
    changes[(changesCounter-1) + 1*T] = T-1;

    plhs[0] = mxCreateDoubleMatrix(1,T,mxREAL);
    outputToolPtr = mxGetPr(plhs[0]);
   /* Be careful to add +1 to path values. This is because C starts from 0
      and Matlab starts from 1. I figured it would be easier to think in C
      anb convert only at the end. Hence, the path[t] + 1.
    */
    for(t=0;t<T;++t)
	outputToolPtr[t] = (double)(path[t]+1);

    /* A junk value for the loglik for backward compatibility.
       We're not scaling so we don't get a loglik value.
    */
    plhs[1] = mxCreateDoubleMatrix(1,1,mxREAL);
    outputToolPtr = mxGetPr(plhs[1]);
    outputToolPtr[0] = loglik;

    plhs[2] = mxCreateDoubleMatrix(changesCounter,4,mxREAL);
    outputToolPtr = mxGetPr(plhs[2]);
    for(t=0;t<changesCounter; ++t) {
	/* +1 because of the Matlab offset from C */
	outputToolPtr[t + 0*changesCounter] = changes[t + 0*T] + 1;
	outputToolPtr[t + 1*changesCounter] = changes[t + 1*T] + 1;
        outputToolPtr[t + 2*changesCounter] = changes[t + 2*T] + 1;
	outputToolPtr[t + 3*changesCounter] = changes[t + 3*T];
    }


    mxFree(delta); mxFree(psi); mxFree(path);
    mxFree(d);
    mxFree(changes);

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



void copyVector(double * Out, double * In, unsigned int L) {
    unsigned int i;

    for(i=0;i<L;++i)
	Out[i] = In[i];

    return;
}

void addVectors(double * Out, double * u, double * v, unsigned int L) {
    unsigned int i;

    for(i=0;i<L;++i)
	Out[i] = u[i] + v[i];

    return;

}

void setVectorToValue(double * A, double value, unsigned int L) {
    unsigned int i;

    for(i=0;i<L;++i)
	A[i] = value;

    return;
}

void setVectorToValue_int(int * A, int value, unsigned int L) {
    unsigned int i;

    for(i=0;i<L;++i)
	A[i] = value;

    return;
}


void maxVectorInPlace(double * Out_value, int * Out_index, double * A, unsigned int L) {
    unsigned int i;
    double maxvalue;
    int index;
    
    maxvalue = A[0];
    index = 0;

    for(i=1;i<L;++i) {
	if (maxvalue < A[i]) {
		index = i;
		maxvalue = A[i];
	}
    }
	
    *Out_value = maxvalue;
    *Out_index = index;

    return;
}
