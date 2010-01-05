#define _USE_MATH_DEFINES 1
#include <math.h>
#include <stdlib.h>
#include <float.h>
#include "util.h"

#ifdef _MSC_VER
#define finite _finite
#define isnan _isnan
#endif

/*
*  Generates a uniformly distributed r.v. between 0 and 1.
*  Kris Popat  6/85
*  Ref: Applied Statistics, 1982 vol 31 no 2 pp 188-190
*  Based on FORTRAN routine by H. Malvar.
*/

/* Sharing a data segment in a DLL:
 * http://msdn2.microsoft.com/en-us/library/h90dkhs0(VS.80).aspx
 * http://www.flounder.com/hooks.htm

pc version:
call "c:\Program Files\Microsoft Visual Studio 8\Common7\Tools\vsvars32.bat"
cl  /c /Zp8 /GR /W3 /EHsc- /Zc:wchar_t- /MD /O2 /Oy- /DNDEBUG random.c
link random.obj /dll /def:random.def

lcc: http://www-users.cs.umn.edu/~mein/blender/plugins/dll.html
http://ems.calumet.purdue.edu/mcss/kraftrl/cs316/runtime/lcclnk-Documentation.txt

cd cygwin\matlab\lightspeed
SET PATH="C:\PROGRAM FILES\MATLAB\R2006A\sys\lcc\bin";%PATH%
lcc -I"C:\PROGRAM FILES\MATLAB\R2006A\sys\lcc\include" random.c
lcclnk -L"C:\PROGRAM FILES\MATLAB\R2006A\sys\lcc\lib" -DLL random.obj random.def
need to include the entry point in 
C:\Program Files\MATLAB\R2006a\sys\lcc\mex\lccstub.c


mex -c util.c
mex randomseed.c util.obj random.lib
mex randbinom.c util.obj random.lib
mex randgamma.c util.obj random.lib
mex sample_hist.c util.obj random.lib

unix version:
cc -fPIC -O -c random.c
cc -shared -Wl,-E -Wl,-soname,`pwd`/librandom.so -o librandom.so random.o

cc util.c librandom.so -lm
./a.out

cc -shared -Wl,-E -o librandom.so random.o
cc util.c librandom.so -lm -Wl,-rpath,`pwd`

mex -c util.c
mex randomseed.c util.o librandom.so
mex randbinom.c util.o librandom.so
mex randgamma.c util.o librandom.so
mex sample_hist.c util.o librandom.so

 */
#pragma data_seg(".seed")
static long ix = 101;
static long iy = 1001;
static long iz = 10001;
static double RandN_previous = 0;
static int RandN_usePrevious = 0;
#pragma data_seg()
#pragma comment(linker,"/section:.seed,rws")

#if 1
double Rand(void)
{
  static float u;
  
  ix = 171*(ix % 177)-2*(ix/177);
  iy = 172*(iy % 176)-2*(iy/176);
  iz = 170*(iz % 178)-2*(iz/178);
  
  if (ix<0) ix = ix + 30269;
  if (iy<0) iy = iy + 30307;
  if (iz<0) iz = iz + 30323;
  
  u = ((float) ix)/30269 +
                ((float) iy)/30307 + ((float) iz)/30323;
  u -= (float)(int)u;
  return(u);
}
#else
/* This provides compatibility with Matlab's random numbers, but it is 
 * 4x slower.
 */
double Rand(void)
{
  mxArray *plhs[1];
  if(mexCallMATLAB(1,plhs,0,NULL,"rand")) {
    mexErrMsgTxt("mexCallMATLAB(rand) failed");
  }
  return mxGetPr(plhs[0])[0];
}
#endif


/* Resets Rand() to generate the same numbers again. */
void ResetSeed(void)
{
  SetSeed(101,1001,10001);
}
/* Sets the seed for Rand(). 
 * The seed determines the sequence of numbers it generates.
 */
void SetSeed(long new_ix, long new_iy, long new_iz)
{
  ix = new_ix;
  iy = new_iy;
  iz = new_iz;
  RandN_usePrevious = 0;
}
/* Gets the seed for Rand().
 */
void GetSeed(long *ix_out, long *iy_out, long *iz_out)
{
  *ix_out = ix;
  *iy_out = iy;
  *iz_out = iz;
  RandN_usePrevious = 0;
}

/* Returns a sample from Normal(0,1)
 */
double RandN(void)
{
  double x,y,radius;
  if(RandN_usePrevious) {
    RandN_usePrevious = 0;
    return RandN_previous;
  }
  /* Generate a random point inside the unit circle */
  do {
    x = 2*Rand()-1;
    y = 2*Rand()-1;
    radius = (x*x)+(y*y);
  } while((radius >= 1.0) || (radius == 0.0));
  /* Box-Muller formula */
  radius = sqrt(-2*log(radius)/radius);
  x *= radius;
  y *= radius;
  RandN_previous = y;
  RandN_usePrevious = 1;
  return x;
}

/* Returns a sample from Gamma(a, 1).
 * For Gamma(a,b), scale the result by b.
 */
double GammaRand(double a)
{
  /* Algorithm:
   * G. Marsaglia and W.W. Tsang, A simple method for generating gamma
   * variables, ACM Transactions on Mathematical Software, Vol. 26, No. 3,
   * Pages 363-372, September, 2000.
   * http://portal.acm.org/citation.cfm?id=358414
   */
  double boost, d, c, v;
  if(a < 1) {
    /* boost using Marsaglia's (1961) method: gam(a) = gam(a+1)*U^(1/a) */
    boost = exp(log(Rand())/a);
    a++;
  } 
  else boost = 1;
  d = a-1.0/3; c = 1.0/sqrt(9*d);
  while(1) {
    double x,u;
    do {
      x = RandN();
      v = 1+c*x;
    } while(v <= 0);
    v = v*v*v;
    x = x*x;
    u = Rand();
    if((u < 1-.0331*x*x) || 
       (log(u) < 0.5*x + d*(1-v+log(v)))) break;
  }
  return( boost*d*v );
}

/* Returns a sample from Beta(a,b) */
double BetaRand(double a, double b)
{
  double g = GammaRand(a);
  return g/(g + GammaRand(b));
}

/* Very fast binomial sampler. 
 * Returns the number of successes out of n trials, with success probability p.
 */
int BinoRand(double p, int n)
{
  int r = 0;
  if(isnan(p)) return 0;
  if(p < DBL_EPSILON) return 0;
  if(p >= 1-DBL_EPSILON) return n;
  if((p > 0.5) && (n < 15)) {
    /* Coin flip method. This takes O(n) time. */
    int i;
    for(i=0;i<n;i++) {
      if(Rand() < p) r++;
    }
    return r;
  }
  if(n*p < 10) {
    /* Waiting time method.  This takes O(np) time. */
    double q = -log(1-p), e = -log(Rand()), s;
    r = n;
    for(s = e/r; s <= q; s += e/r) {
      r--;
      if(r == 0) break;
      e = -log(Rand());
    }
    r = n-r;
    return r;
  }
  if (1) {
    /* Recursive method.  This makes O(log(log(n))) recursive calls. */
    int i = (int)(p*(n+1));
    double b = BetaRand(i, n+1-i);
    if(b <= p) r = i + BinoRand((p-b)/(1-b), n-i);
    else r = i - 1 - BinoRand((b-p)/b, i-1);
    return r;
  }
}

