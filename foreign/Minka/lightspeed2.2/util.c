/* C implementations of useful functions.
 * Written by Tom Minka (unless otherwise noted).
 */

#define _USE_MATH_DEFINES 1
#include <math.h>
#include <stdlib.h>
#include <float.h>
#include "util.h"
#include "mex.h"

#ifdef _MSC_VER
#define finite _finite
#define isnan _isnan
#endif

#ifndef M_PI
#define M_PI       3.14159265358979323846
#endif

#ifdef	 __USE_ISOC99
/* INFINITY and NAN are defined by the ISO C99 standard */
#else
double my_infinity(void) {
  double zero = 0;
  return 1.0/zero;
}
double my_nan(void) {
  double zero = 0;
  return zero/zero;
}
#define INFINITY my_infinity()
#define NAN my_nan()
#endif

/****************************************************************************/

double logSum(double a, double b)
{
  /* make a the larger number */
  if(a < b) {
    double t = a; a = b; b = t;
  }
  /* log(exp(a) + exp(b)) = a + log(1 + exp(b-a)) */
  if(!finite(b)) return a;
  return a + log(1 + exp(b-a));
}

#define CACHE_SIZE 200

/* Requires: n >= 0 */
double pochhammer(double x, int n)
{
  static double cache_x = -1;
  static double cache_v[CACHE_SIZE];
  static int max_cached;
  double result;
  int i;
  /* the maximum n for which we have a cached value */
  if(n == 0) return 0;
  if(n > CACHE_SIZE) {
    if(x >= 1.e4*n) {
      return log(x) + (n-1)*log(x+n/2);
    }
    return gammaln(x+n) - gammaln(x);
  }
  if(x != cache_x) {
    max_cached = 1;
    cache_v[0] = log(x);
    cache_x = x;
  }
  if(n <= max_cached) return cache_v[n-1];
  result = cache_v[max_cached-1];
  x = x + max_cached-1;
  for(i=max_cached;i<n;i++) {
    x = x + 1;
    result += log(x);
    cache_v[i] = result;
  }
  max_cached = n;
  return result;
}

/* Requires: n >= 0 */
double slow_pochhammer(double x, int n)
{
  double result;
  if(n == 0) return 0;
  if(n <= 20) {
    int i;
    double xi = x;
    /* this assumes x is not too large */
    result = xi;
    for(i=n-1; i > 0; i--) {
      xi = xi + 1;
      result *= xi;
    }
    result = log(result);
  }
  else if(x >= 1.e4*n) {
    result = log(x) + (n-1)*log(x+n/2);
  }
  else result = gammaln(x+n) - gammaln(x);
  return result;
}

double di_pochhammer(double x, int n)
{
  static double cache_x = -1;
  static double cache_v[CACHE_SIZE];
  static int max_cached;
  double result;
  int i;
  /* the maximum n for which we have a cached value */
  if(n == 0) return 0;
  if(n > CACHE_SIZE) {
    return digamma(x+n) - digamma(x);
  }
  if(x != cache_x) {
    max_cached = 1;
    cache_v[0] = 1/x;
    cache_x = x;
  }
  if(n <= max_cached) return cache_v[n-1];
  result = cache_v[max_cached-1];
  x = x + max_cached-1;
  for(i=max_cached;i<n;i++) {
    x = x + 1;
    result += 1/x;
    cache_v[i] = result;
  }
  max_cached = n;
  return result;
}

double slow_di_pochhammer(double x, int n)
{
  double result;
  if(n == 0) return 0;
  if(n <= 20) {
    int i;
    double xi = x;
    result = 1/xi;
    for(i=n-1; i > 0; i--) {
      xi = xi + 1;
      result += 1/xi;
    }
  }
  else result = digamma(x+n) - digamma(x);
  return result;
}

double tri_pochhammer(double x, int n)
{
  static double cache_x = -1;
  static double cache_v[CACHE_SIZE];
  static int max_cached;
  double result;
  int i;
  /* the maximum n for which we have a cached value */
  if(n == 0) return 0;
  if(n > CACHE_SIZE) {
    return trigamma(x+n) - trigamma(x);
  }
  if(x != cache_x) {
    max_cached = 1;
    cache_v[0] = -1/(x*x);
    cache_x = x;
  }
  if(n <= max_cached) return cache_v[n-1];
  result = cache_v[max_cached-1];
  x = x + max_cached-1;
  for(i=max_cached;i<n;i++) {
    x = x + 1;
    result -= 1/(x*x);
    cache_v[i] = result;
  }
  max_cached = n;
  return result;
}

double slow_tri_pochhammer(double x, int n)
{
  double result;
  if(n == 0) return 0;
  if(n <= 20) {
    result = -1/(x*x);
    n--;
    while(n > 0) {
      x = x + 1;
      result -= 1/(x*x);
      n--;
    }
    return result;
  }
  return trigamma(x+n) - trigamma(x);
}

/* Logarithm of multivariate Gamma function, defined as
 * Gamma_d(x) = pi^(d*(d-1)/4)*prod_(i=1..d) Gamma(x + (1-i)/2)
 * http://en.wikipedia.org/wiki/Multivariate_gamma_function
 */
double gammaln2(double x, double d)
{
  #define M_lnPI 1.14472988584940
  double r = d*(d-1)/4*M_lnPI;
  int i;
  for(i=0; i<d; i++) r += gammaln(x + (1-i)/2);
  return r;
}

/* Logarithm of the gamma function.
   Returns NaN for negative arguments, even though log(gamma(x)) may
   actually be defined.
*/
double gammaln(double x)
{
  #define M_lnSqrt2PI 0.91893853320467274178
  static double gamma_series[] = {
    76.18009172947146,
    -86.50532032941677,
    24.01409824083091,
    -1.231739572450155,
    0.1208650973866179e-2,
    -0.5395239384953e-5
  };
  int i;
  double denom, x1, series;
  if(x < 0) return NAN;
  if(x == 0) return INFINITY;
  if(!finite(x)) return x;
  /* Lanczos method */
  denom = x+1;
  x1 = x + 5.5;
  series = 1.000000000190015;
  for(i = 0; i < 6; i++) {
    series += gamma_series[i] / denom;
    denom += 1.0;
  }
  return( M_lnSqrt2PI + (x+0.5)*log(x1) - x1 + log(series/x) );
}

/* The digamma function is the derivative of gammaln.

   Reference:
    J Bernardo,
    Psi ( Digamma ) Function,
    Algorithm AS 103,
    Applied Statistics,
    Volume 25, Number 3, pages 315-317, 1976.

    From http://www.psc.edu/~burkardt/src/dirichlet/dirichlet.f
    (with modifications for negative numbers and extra precision)
*/
double digamma(double x)
{
  double neginf = -INFINITY;
  static const double c = 12,
    d1 = -0.57721566490153286,
    d2 = 1.6449340668482264365, /* pi^2/6 */
    s = 1e-6,
    s3 = 1./12,
    s4 = 1./120,
    s5 = 1./252,
    s6 = 1./240,
    s7 = 1./132,
    s8 = 691./32760,
    s9 = 1./12,
    s10 = 3617./8160;
  double result;
  /* Illegal arguments */
  if((x == neginf) || isnan(x)) {
    return NAN;
  }
  /* Singularities */
  if((x <= 0) && (floor(x) == x)) {
    return neginf;
  }
  /* Negative values */
  /* Use the reflection formula (Jeffrey 11.1.6):
   * digamma(-x) = digamma(x+1) + pi*cot(pi*x)
   *
   * This is related to the identity
   * digamma(-x) = digamma(x+1) - digamma(z) + digamma(1-z)
   * where z is the fractional part of x
   * For example:
   * digamma(-3.1) = 1/3.1 + 1/2.1 + 1/1.1 + 1/0.1 + digamma(1-0.1)
   *               = digamma(4.1) - digamma(0.1) + digamma(1-0.1)
   * Then we use
   * digamma(1-z) - digamma(z) = pi*cot(pi*z)
   */
  if(x < 0) {
    return digamma(1-x) + M_PI/tan(-M_PI*x);
  }
  /* Use Taylor series if argument <= S */
  if(x <= s) return d1 - 1/x + d2*x;
  /* Reduce to digamma(X + N) where (X + N) >= C */
  result = 0;
  while(x < c) {
    result -= 1/x;
    x++;
  }
  /* Use de Moivre's expansion if argument >= C */
  /* This expansion can be computed in Maple via asympt(Psi(x),x) */
  if(x >= c) {
    double r = 1/x, t;
    result += log(x) - 0.5*r;
    r *= r;
#if 0
    result -= r * (s3 - r * (s4 - r * (s5 - r * (s6 - r * s7))));
#else
    /* this version for lame compilers */
    t = (s5 - r * (s6 - r * s7));
    result -= r * (s3 - r * (s4 - r * t));
#endif
  }
  return result;
}

/* The trigamma function is the derivative of the digamma function.

   Reference:

    B Schneider,
    Trigamma Function,
    Algorithm AS 121,
    Applied Statistics, 
    Volume 27, Number 1, page 97-99, 1978.

    From http://www.psc.edu/~burkardt/src/dirichlet/dirichlet.f
    (with modification for negative arguments and extra precision)
*/
double trigamma(double x)
{
  double neginf = -INFINITY,
    small = 1e-4,
    large = 8,
    c = 1.6449340668482264365, /* pi^2/6 = Zeta(2) */
    c1 = -2.404113806319188570799476,  /* -2 Zeta(3) */
    b2 =  1./6,
    b4 = -1./30,
    b6 =  1./42,
    b8 = -1./30,
    b10 = 5./66;
  double result;
  /* Illegal arguments */
  if((x == neginf) || isnan(x)) {
    return NAN;
  }
  /* Singularities */
  if((x <= 0) && (floor(x) == x)) {
    return neginf;
  }
  /* Negative values */
  /* Use the derivative of the digamma reflection formula:
   * -trigamma(-x) = trigamma(x+1) - (pi*csc(pi*x))^2
   */
  if(x < 0) {
    result = M_PI/sin(-M_PI*x);
    return -trigamma(1-x) + result*result;
  }
  /* Use Taylor series if argument <= small */
  if(x <= small) {
    return 1/(x*x) + c + c1*x;
  }
  result = 0;
  /* Reduce to trigamma(x+n) where ( X + N ) >= B */
  while(x < large) {
    result += 1/(x*x);
    x++;
  }
  /* Apply asymptotic formula when X >= B */
  /* This expansion can be computed in Maple via asympt(Psi(1,x),x) */
  if(x >= large) {
    double r = 1/(x*x), t;
#if 0
    result += 0.5*r + (1 + r*(b2 + r*(b4 + r*(b6 + r*(b8 + r*b10)))))/x;
#else
    t = (b4 + r*(b6 + r*(b8 + r*b10)));
    result += 0.5*r + (1 + r*(b2 + r*t))/x;
#endif
  }
  return result;
}

unsigned *ismember_sorted(double *a, unsigned a_len, double *s, unsigned s_len)
{
  /* returns a vector tf where tf[i] = 1 if a[i] is in s. */
  unsigned *tf = mxCalloc(a_len,sizeof(unsigned));
  unsigned i,j=0;
  if(j == s_len) return tf;
  for(i=0;i<a_len;i++) {
    while(s[j] < a[i]) {
      j++;
      if(j == s_len) return tf;
    }
    if(s[j] == a[i]) tf[i] = 1;
  }
  return tf;
}


