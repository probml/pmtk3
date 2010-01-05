/* Test the time for various math operations.
 * This should be compiled as a standalone program, NOT a mex file:
 *   cc -O3 -o test_flops test_flops.c -lm
 * These options don't seem to help:
 *   -ffast-math -funroll-loops -fprefetch-loop-arrays
 *   -march=pentium4 -mfpmath=sse -msse -msse2 -malign-double
 *
 * On Pentium 4, VC gives better results:
 * cl /O2 /G7 /Oi- test_flops.c
 * /Oi- disables intrinsic functions, making exp faster but sqrt slower.
 * These options don't seem to help: /arch:SSE
 *
 * Results do not seem to be reliable within mex.
 */
/* source code at:
 http://www.opencores.org/cvsweb.shtml/or1k/newlib/newlib/libm/mathfp/s_exp.c
according to source:
exp 20 flops
log 22 flops
pow 43 (naive alg)
*/
#define STANDALONE 1

#if STANDALONE
#include <stdio.h>
#else
#include "mex.h"
#endif
#include <math.h>
#include <time.h>

#define M 10000
#define N 10000

#if STANDALONE
int main()
#else
void mexFunction(int nlhs, mxArray *plhs[],
                 int nrhs, const mxArray *prhs[])
#endif
{
  int i,j;
  clock_t t,t1,t2;
  clock_t t_loop,t_mul;
  double a[N],b[N],c[N];

  for(i=0;i<N;i++) { b[i]=i; c[i] = N-i; }
#if 0
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) { a[i] = b[i]*c[i]; } t1=clock()-t;
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) { a[i] = b[i]*c[i]; a[i] = b[i]*c[i]; } t2=clock()-t;
  t_loop = 2*t1 - t2;
  printf("time for loop: \t%d\n", t_loop);
#else
  t_loop = 0;
#endif
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = b[i]*c[i]; t=clock()-t-t_loop;
  printf("time for multiply: \t%d\n", t);
  t_mul = t;
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = b[i]+c[i]; t=clock()-t-t_loop;
  printf("time for add: \t%d\n", t);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = (b[i]<c[i]); t=clock()-t-t_loop;
  printf("time for <: \t%d\tflops=%g\n", t, (double)t/t_mul);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = (b[i]==c[i]); t=clock()-t-t_loop;
  printf("time for ==: \t%d\tflops=%g\n", t, (double)t/t_mul);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = b[i]/c[i]; t=clock()-t-t_loop;
  printf("time for /: \t%d\tflops=%g\n", t, (double)t/t_mul);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = sqrt(b[i]); t=clock()-t-t_loop;
  printf("time for sqrt: \t%d\tflops=%g\n", t, (double)t/t_mul);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = exp(b[i]); t=clock()-t-t_loop;
  printf("time for exp: \t%d\tflops=%g\n", t, (double)t/t_mul);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = log(b[i]); t=clock()-t-t_loop;
  printf("time for log: \t%d\tflops=%g\n", t, (double)t/t_mul);
  t=clock(); for(j=0;j<M;j++) for(i=0;i<N;i++) a[i] = pow(b[i],c[i]); t=clock()-t-t_loop;
  printf("time for pow: \t%d\tflops=%g\n", t, (double)t/t_mul);
}
