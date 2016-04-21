"""Gaussian process using a cubic spline kernel.

Given a GP prior on the function f(t), and noisy Gaussian observations of
the form y(t) ~ N(f(t), sigmaf) and dy(t) ~ N(df(f), sigmadf), where df
is the derivative of f, the posterior on f, df is also a GP.

For details, see
 "Probabilistic line searches for stochastic optimization",
 M. Mahsereci and P. Hennig, NIPS 2015 (http://arxiv.org/abs/1502.02846)
 
The code is a direct translation from the matlab code at
https://ei.is.tuebingen.mpg.de/uploads_file/attachment/attachment/242/probLineSearch.zip
"""

import numpy as np

class CubicSplineGaussianProcess(object):
    """Gaussian process based on cubic spline."""
    def __init__(self, sigmaf, sigmadf):
        self.sigmaf = sigmaf
        self.sigmadf = sigmadf
        # Create empty list to store visited values
        self.t_vals = []
        self.y_vals = []
        self.dy_vals = []
        self.dy_projected_vals = [] 
        self.sigmaf_vals = []
        self.sigmadf_vals = []
        # Create storage for mean function and its derivatives
        self.m_fun = None
        self.d1m_fun = None
        self.d2m_fun = None
        self.d3m_fun = None
        # Create storage for variance function and its derivatives
        self.v_fun = None
        self.vd_fun = None
        self.dvd_fun = None
        # Create storage for covariance function and its derivatives
        self.v0f_fun = None
        self.vd0f_fun = None
        self.v0df_fun = None
        self.vd0df_fun = None
        
    def update(self, tt, y, dy, dy_projected, var_f, var_df):
        # store data
        self.t_vals.append(tt)
        self.y_vals.append(y)
        self.dy_vals.append(np.copy(dy)) # vectors are passed by ref.
        self.dy_projected_vals.append(dy_projected)
        self.sigmaf_vals.append(var_f)
        self.sigmadf_vals.append(var_df)
          
        # Make local aliases for readability
        tv = self.t_vals # settings we have already evaluated
        def k(a, b):
            return kernel.k_fun(a, b)
        def dk(a, b):
            return kernel.dk_fun(a, b)
        def ddk(a, b):
            return kernel.ddk_fun(a, b)
        def dddk(a, b):
            return kernel.dddk_fun(a, b)
        def kd(a, b):
            return kernel.kd_fun(a, b)
        def dkd(a, b):
            return kernel.dkd_fun(a, b)
        def ddkd(a, b):
            return kernel.ddkd_fun(a, b)
        def dddkd(a, b):
            return kernel.dddkd_fun(a, b)
                   
        # Implement part of eqn 7
        gram = make_gram_matrix(self.t_vals, self.sigmaf, self.sigmadf)
        yy = c_[self.y_vals, self.dy_projected_vals]
        v = linalg.solve(gram, yy)  # G^{-1} * yy, column vector
        
        # Posterior mean of f is given by
        # mu(t) = m(t) = ip([k(tv, t); kd(tv, t)], v)
        # To find the minimum of f in each 'cell', we need to compute
        # mu'(t) = d1dm, mu''(t) = d2m, mu'''(t) = d3m. These are given by
        # d1m(t) = ip([dk(tvals, t); dkd(tvals, t)], v), etc
        self.m_fun = lambda t: np.inner(v, r_[k(t, tv), kd(t, tv)])
        self.d1m_fun = lambda t: np.inner(v, r_[dk(t, tv), dkd(t, tv)])
        self.d2m_fun = lambda t: np.inner(v, r_[ddk(t, tv), ddkd(t, tv)])
        self.d3m_fun = lambda t: np.inner(v, r_[dddk(t, tv), dddkd(t, tv)])
        
        # posterior covariance v(t,t') = cov[f(t), f(t')] is given by eqn 7:
        # v(t,t') = k(t,t') - ip([k(tv,t); kd(tv,t)], inv(G) * [k(tv,t'); kd(tv,t')])
        
        # posterior marginal variance v(t) = v(t,t)
        self.v_fun = lambda t: k(t, t) - r_[k(t,tv), kd(t,tv)] * \
            linalg.solve(gram, c_[k(t,tv), kd(t,tv)])
            
        # vd(t) = d/dt' v(t,t') 
        self.vd_fun = lambda t: kd(t, t) - r_[k(t,tv), kd(t,tv)] * \
            linalg.solve(gram, c_[dk(t,tv), dkd(t,tv)])
            
        # dvd(t) = d/dt d/dt' v(t,t')
        self.dvd_fun = lambda t: dkd(t, t) - r_[dk(t,tv), dkd(t,tv)] * \
            linalg.solve(gram, c_[dk(t,tv), dkd(t,tv)])
        
        # v0f(t) = cov[f(t), f(0)] 
        self.v0f_fun = lambda t: k(0, t) - r_[k(0,tv), kd(0,tv)] * \
            linalg.solve(gram, c_[k(t,tv), kd(t,tv)])
        
        # vd0f(t) 
        self.vd0f_fun = lambda t: dk(0, t) - r_[dk(0,tv), dkd(0,tv)] * \
            linalg.solve(gram, c_[k(t,tv), kd(t,tv)])
            
        # v0df(t) 
        self.v0df_fun = lambda t: kd(0, t) - r_[k(0,tv), kd(0,tv)] * \
            linalg.solve(gram, c_[dk(t,tv), dkd(t,tv)])
        
        # vd0df(t)
        self.vd0df_fun = lambda t: dkd(0, t) - r_[dk(0,tv), dkd(0,tv)] * \
            linalg.solve(gram, c_[dk(t,tv), dkd(t,tv)])
            
def make_gram_matrix(tvals, sigmaf, sigmadf):
    # Equation 7
    n = len(tvals)
    kTT = np.zeros([n, n])
    kdTT = np.zeros([n, n])
    dkdTT = np.zeros([n, n])
    for i in range(n):
        for j in range(n):
            kTT(i, j) = kernel.k(tvals(i), tvals(j))
            kdTT(i, j) = kernel.kd(tvals(i), tvals(j))
            dkdTT(i, j) = kernel.dkd(tvals(i), tvals(j))
            
    sigma = np.concatenate(sigmaf**2 * np.ones(n),
                            sigmadf**2 * np.ones(n))
    gram = np.diag(sigma) + \
        np.bmat([[kTT, kdTT], [kdTT.T, dkdTT]]).asarray()
    return gram
    
 
def k_fun(a, b):
    # Eqn 4
    offset = 10  # tau in paper, needed for numerical stability
    aa = a + offset  # \tilde{t} in paper
    bb = b + offset  # \tilde{t'} in paper
    val = (1.0 / 3) * np.power(np.min(aa, bb), 3) + \
        (1.0 / 2) * np.abs(a-b) * np.power(np.min(aa, bb), 2)
    return val

def kd_fun(a, b):
    # Eqn 6, d/dt' k(t,t')
    offset = 10  
    aa = a + offset  
    bb = b + offset  
    val = (a < b) * np.power(aa, 2)/2 + \
        (a >= b) * (aa * bb - 0.5 * np.power(bb, 2))
    return val
    
def dk_fun(a, b):
    # Eqn 6, d/dt k(t,t')
    offset = 10  
    aa = a + offset  
    bb = b + offset  
    val = (a > b) * np.power(bb, 2)/2 + \
        (a <= b) * (aa * bb - 0.5 * np.power(aa, 2))
    return val
    
def dkd_fun(a, b):
    # Eqn 6, d^2/dt dt' k(t,t')
    offset = 10  
    aa = a + offset  
    bb = b + offset 
    val = np.min(aa, bb)
    return val
    
def ddk_fun(a, b):
    # Eqn 8, d^2/dt^2 k(t,t')
    return (a <= b) * (b-a)

def ddkd_fun(a, b):
    # Eqn 8, d^2/dt^2 d/dt' k(t,t')
    return (a <= b) 
    
def dddk_fun(a, b):
    # Eqn 8, d^3/dt^3 k(t,t')
    return -(a <= b) 
    
def dddkd_fun(a, b):
    # Eqn 8, d^3/dt^3 d/dt' k(t,t')
    return np.zeros(max(len(a), len(b)))