# "Computation of the bivariate normal integral", Z. Drezner, 
# Mathematics of Comptuation,  32(141):277-279, 1978
# Translated by kpmurphy from matlab function
# http://www.math.wsu.edu/faculty/genz/software/matlab/bvn.m
#       Alan Genz, Department of Mathematics
#       Washington State University, Pullman, Wa 99164-3113
#       Email : alangenz@wsu.edu
#

import numpy as np
import scipy

def phid(z):
    '''Normal cdf'''
    return scipy.special.erfc( -z/np.sqrt(2) )/2

def bvn( xl, xu, yl, yu, r ):
    '''
    A function for computing bivariate normal probabilities.
    Specifically, iy calculates the probability that 
        xl < x < xu and yl < y < yu, 
    with correlation coefficient r.
    '''
    p = bvnu(xl,yl,r) - bvnu(xu,yl,r) - bvnu(xl,yu,r) + bvnu(xu,yu,r); 
    p = max( 0, min( p, 1 ) );
    return p
    
    
def bvnu( dh, dk, r ):
    '''
    A function for computing bivariate normal probabilities.
    It calculates the probability that x > dh and y > dk. 
    parameters:  
      dh 1st lower integration limit
      dk 2nd lower integration limit
      r   correlation coefficient
    Example: p = bvnu( -3, -1, .35 )
    Note: to compute the probability that x < dh and y < dk, 
    use bvnu( -dh, -dk, r ). 
    '''
    if np.isposinf(dh) or np.isposinf(dk):
         return 0
    if np.isneginf(dh):
        if np.isneginf(dk):
            return 1
        else:
            return phid(-dk)
    elif np.isneginf(dk):
        return phid(-dh)
    elif r==0:
        return phid(-dh) * phid(-dk)
    else:
        tp = 2*np.pi;
        h = dh;
        k = dk;
        hk = h*k;
        bvn = 0; 
        if abs(r) < 0.3:
            # Gauss Legendre points and weights, n =  6    
            w = np.array([0.1713244923791705, 0.3607615730481384, 0.4679139345726904]);
            x = np.array([0.9324695142031522, 0.6612093864662647, 0.2386191860831970]);
        elif abs(r) < 0.75:
            # Gauss Legendre points and weights, n = 12
            w = np.array([.04717533638651177, 0.1069393259953183, 0.1600783285433464, 
                            0.2031674267230659, 0.2334925365383547, 0.2491470458134029]);
            x = np.array([0.9815606342467191, 0.9041172563704750, 0.7699026741943050, 
                            0.5873179542866171, 0.3678314989981802, 0.1252334085114692]);
        else:
            # Gauss Legendre points and weights, n = 20
            w = np.array([.01761400713915212, .04060142980038694, .06267204833410906, 
                            .08327674157670475, 0.1019301198172404, 0.1181945319615184,
                            0.1316886384491766, 0.1420961093183821, 0.1491729864726037,
                            0.1527533871307259]);
            x = np.array([0.9931285991850949, 0.9639719272779138, 0.9122344282513259,
                        0.8391169718222188, 0.7463319064601508, 0.6360536807265150,
                        0.5108670019508271, 0.3737060887154196, 0.2277858511416451,
                        0.07652652113349733]);
        w = np.concatenate([w, w])
        x = np.concatenate([1-x, 1+x])
        if abs(r) < 0.925:
            hs = (h*h + k*k)/2.0
            asr = np.arcsin(r)/2.0
            sn = np.sin(asr*x); # vector
            bvn = np.inner(np.exp((sn*hk-hs)/(1-np.square(sn))), w);
            bvn = bvn*asr/tp + phid(-h)*phid(-k);
        else: # extra complexity to handle highly correlated case
            if r < 0:
                k = -k; hk = -hk
            if abs(r) < 1:
                ass = 1-r**2; # renamed as to ass
                a = np.sqrt(ass);
                bs = (h-k)**2;
                asr = -( bs/ass + hk )/2;
                c = (4-hk)/8 ;
                d = (12-hk)/80;
                if asr > -100:
                    bvn = a*np.exp(asr)*(1-c*(bs-ass)*(1-d*bs)/3+c*d*ass**2);
                if hk  > -100:
                    b = np.sqrt(bs);
                    sp = np.sqrt(tp)*phid(-b/a);
                    bvn = bvn - np.exp(-hk/2)*sp*b*( 1 - c*bs*(1-d*bs)/3 );
                a = a/2;
                xs = np.square(a*x);
                asr = -( bs/xs + hk )/2;
                ix = ( asr > -100 );
                xs = xs[ix];
                sp = ( 1 + c*xs * (1+5*d*xs) );
                rs = np.sqrt(1-xs);
                ep = np.exp( -(hk/2)*xs / np.square(1+rs)) / rs;
                ip = np.inner(np.exp(asr[ix]) * (sp-ep), w[ix])
                bvn = (a*ip - bvn)/tp;
            if r > 0:
                bvn =  bvn + phid( -max( h, k ) ); 
            elif h >= k:
                bvn = -bvn;
            else:
                if h < 0:
                    L = phid(k)-phid(h);
                else:
                    L = phid(-h)-phid(-k);
                bvn =  L - bvn;
        p = max([0, min([1, bvn])]);
        return p
                                        
def bvn_test():
    # we calculate the exact values using the matlab code
    # (which has been verified using numerical integration)
    rtol = 1e-3
    atol = 1e-3
    p = bvn(-1, 1, -1, 1, 0.1)
    assert(np.allclose(0.4672, p, rtol, atol))
    
    p = bvn(-1, 1, -1, 1, 0.5)
    assert(np.allclose(0.4980, p, rtol, atol))
    
    p = bvn(-1, 1, -1, 1, 0.99)
    assert(np.allclose(0.6554, p, rtol, atol))

    p = bvn(-np.inf, 1, -1, 1, 0.1)
    assert(np.allclose(0.5750, p, rtol, atol))
    
    p = bvn(-np.inf, 1, -1, 1, 0.5)
    assert(np.allclose(0.5903, p, rtol, atol))
    
    p = bvn(-np.inf, 1, -1, 1, 0.99)
    assert(np.allclose(0.6690, p, rtol, atol))
    
    p = bvn(-np.inf, 1, -1, np.inf, -0.1)
    assert(np.allclose(0.7140, p, rtol, atol))
    
    p = bvn(-np.inf, 1, -1, np.inf, -0.5)
    assert(np.allclose(0.7452, p, rtol, atol))
    
    p = bvn(-np.inf, 1, -1, np.inf, -0.99)
    assert(np.allclose(0.8277, p, rtol, atol))
    
    print 'All assertions passed!'
    
if __name__ == "__main__":
    bvn_test()