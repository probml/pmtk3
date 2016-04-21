"""Computes 1d line search for noisy function optimization.

Implements the algorithm of this paper:
 "Probabilistic line searches for stochastic optimization",
 M. Mahsereci and P. Hennig, NIPS 2015 (http://arxiv.org/abs/1502.02846)
 
The code is a direct translation from the matlab code at
https://ei.is.tuebingen.mpg.de/uploads_file/attachment/attachment/242/probLineSearch.zip

The linesearch operates along the univariate domain x(t) = x + t*s,
where x is the starting parameter value (vector), and s is the search
direction (vector), and t > 0 is the distance to travel.
Let us define f(t) = L(x(t)) and df(t) = <s, deriv L(x(t))>,
where L(x) is the loss (objective function) at x.
The algorithm observes noisy versions of these quantities, denoted by
y(t) an dy(t). From this, it infers a posterior over f and df,
and thus decides probabilistically how far to search along s.
"""

import numpy as np
from collections import namedtuple

import cubic_spline_gp
import bivariate_normal_integral

# We stop searching if prob(wolfe conditions hold) > wolfe_threshold
# The paper claims any value between 0 and 0.8 works well.
# Their matlab code uses 0.3
wolfe_threshold = 0.3

class LineSearchHistory(object):
    """Object to store history of values during line search."""
    def __init__(self):
        self.t_vals = []
        self.y_vals = []
        self.dy_vals = []
        self.dy_projected_vals = [] 
        self.sigmaf_vals = []
        self.sigmadf_vals = []
  
    def update(self, t, y, dy, dy_projected, var_f, var_df):
        self.t_vals.append(t)
        self.y_vals.append(y)
        self.dy_vals.append(np.copy(dy)) # vectors are passed by ref.
        self.dy_projected_vals.append(dy_projected)
        self.sigmaf_vals.append(var_f)
        self.sigmadf_vals.append(var_df)
        
    def extract(self, ndx):
        t = self.t_vals[ndx]
        y = self.y_vals[ndx]
        dy = self.dy_vals[ndx]
        dy_projected = self.dy_projected_vals[ndx]
        var_f = self.sigmaf_vals[ndx]
        var_df = self.sigmadf_vals[ndx]
        return t, y, dy, dy_projected, var_f, var_df 
              
def prob_line_search(func, x0, f0, df0, search_direction, step_size, \
        avg_step_size, var_f0, var_df0, verbose=True):
    """1d probabilistic line search.
    
    For details, see this paper :
    "Probabilistic line searches for stochastic optimization",
    M . Mahsereci and P. Hennig, NIPS 2015 (http://arxiv.org/abs/1502.02846)
    
    Args:
        func: function with signature [f, df, var_f, var_df] = func(x) 
        x0: D*1 vector containing current parameter values
        f0: scalar containing f(x0), equal to previous output y_t
        df0: D*1 vector containing df(x0), equal to previous y_tt
        search_direction: D*1 vector proportional to df(x0)
        step_size: scalar step size, equal to previous output step_size
        avg_step_size: running average of step_size
        var_f0: scalar variance of f(x0), equal to previous var_f_tt
        var_df0: D*1 variance of df(x0), equal to previous var_df_tt
        verbose: set to true to print debug
        
    Returns:
        named tuple with these fields:
            new_step_size: accepted step_size * 1.3 (for next iteration)
            step_size_avg: running average of step_size
            x_tt: new parameter value
            y_tt: f(x_tt)
            dy_tt: df(x_tt)
            var_f_tt: variance of f(x_tt)
            var_df_tt: var of df(x_tt)
    """
    extrapolation_size = 1
    # scale f and df according to 1/(beta * step_size)
    beta = np.abs(np.inner(search_direction, df0))
    # scaled noise
    sigmaf = np.sqrt(var_f0) / (step_size * beta)
    sigmadf = np.sqrt(np.inner(np.square(search_direction), var_df0)) / beta

    # First iteration
    gp = cubic_spline_gp.gp(sigmaf, sigmadf)
    tt = 1 # current distance traveled along search direction
    y = 0
    dy = df0
    dy_projected = np.inner(df0, search_direction) / beta
    history = LineSearchHistory()
    history.update(tt, y, dy, dy_projected, var_f0, var_df0)
    tv = history.t_vals
    gp.compute_posterior(tv, history.y_vals, history.dy_projected_vals)

    maxiter = 7
    for iter in range(maxiter):
        y, dy, var_f, var_df = func(x0 + tt * step_size * search_direction)
        if np.isinf(y) or np.isnan(y):
            raise ValueError('function value is inf or nan')
        y = (y - f0) / (step_size * beta)
        dy_projected = np.inner(dy, search_direction) / beta
        current_ndx = history.update(tt, y, dy, dy_projected, var_f0, \
                                    var_df0)
        tv = history.t_vals
        gp.compute_posterior(tv, history.y_vals, history.dy_projected_vals)
        
        # If current point good enough, return.
        if prob_wolfe_conditions(tt, gp) > wolfe_threshold:
            return compute_outputs(history, current_ndx)
        
        # Find point with current lowest mean, and its gradient.
        means = [gp.m_fun(t) for t in tv]
        dmeans = [gp.d1m_fun(t) for t in tv]
        min_ndx = np.argmin(means)
        
        # If gradient is small and variance nearly deterministic, return.
        if ((abs(dmeans[min_ndx]) < 1e-4) and
            (gp.vd_fun(tv[min_ndx]) < 1e-4)):
            return compute_outputs(history, min_ndx)
       
        tsorted = np.sort(tv)
        tcand, mcand, scand, twolfe, reeval = \
            find_candidates(tsorted, gp, verbose)
            
        # If at least one point is acceptable, pick lowest and return.
        if twolfe is not None:
            mwolfe = [gp.m_fun(t) for t in twolfe]
            min_ndx = np.argmin(mwolfe)
            tt = twolfe[min_ndx]
            mask = (tt == gp.t_vals)
            ndx = mask.nonzero()[0][0]
            return compute_outputs(history, ndx)
        
        # One extrapolation step
        if not reeval:
            newt = max(gp.t_vals) + extrapolation_size
            tcand.append(newt)
            mcand.append(gp.m_fun(newt))
            scand.append(np.sqrt(gp.v_fun(newt)))
        
        # Pick best candidate based on expected improvement and
        # wolfe conditions.
        eicand = expected_improvement(mcand, scand, means[min_ndx])
        ppcand = [prob_wolfe_conditions(t, gp) for t in tcand]
        ndx_best = np.argmax(eicand * ppcand)
        # If we chose an extrapolation point, increase extrapolation factor
        if tcand[ndx_best] == tt + extrapolation_size:
            extrapolation_size *= 2
        tt = tcand[ndx_best]
    
    # Exceeded max iterations, return best known point
    means = [gp.m_fun(t) for t in history.t_vals]
    min_ndx = np.argmin(means)
    return compute_outputs(history, min_ndx)
                    
   
                                     
def find_candidates(tsorted, gp, verbose):
    tcand = []  # positions of candidate points
    mcand = []  # means of candidate points
    scand = []  # standard deviations of candidate points
    twolfe = [] # list of points that satisfy wolfe condition
    n = len(tsorted)
    reeval = False # whether to re-evaluate function at current point
    for i in range(n-1):
        trep = tsorted[i] + 1e-6 * (tsorted[i+1] - tsorted[i])
        cc = cubic_minimum(trep)
        # add point to candidate list if min lies between t[i] and t[i+1]
        if (cc > tsorted[i]) and (cc < tsorted[i+1]):
            tcand.append(cc)
            mcand.append(gp.m_fun(cc))
            scand.sqrt(gp.v_fun(cc))
        else:
            # no minimum, just take half way (for first point only)
            if (i == 0) and (gp.d1m_fun(0) > 0):
                if verbose:
                    print 'fn seems steep, re-evaluating close to start'
                reeval = True
                tcand = 0.1 * (tsorted[i] + tsorted[i+1])  # append??
                mcand.append(gp.m_fun(tcand))
                scand.append(np.sqrt(gp.v_fun(tcand)))
                break  # terminate i loop
        # can we add this to the list of acceptable points?
        if (i > 0) and (prob_wolfe_conditions(tsorted[i], gp) > wolfe_threshold):
            twolfe.append(tsorted[i])
    return tcand, mcand, scand, twolfe, reeval
    
    
def compute_outputs(y, dy, var_f, var_df, step_size, step_size_avg,
                    search_direction, x0, f0, tt, beta, verbose):
    x_tt = x0 + tt * step_size * search_direction # accepted position
    y_tt = y * step_size * beta + f0 # fn val at accepted position ??
    dy_tt = dy
    var_f_tt = var_f
    var_df_tt = var_df
    new_step_size = tt * step_size * 1.3
    gamma = 0.9 # running average weight
    step_size_avg = gamma * step_size_avg + (1 - gamma) * tt * step_size
    # if proposed next step size is too big or too small, reset to average
    if (new_step_size > 100*step_size_avg) or \
        (new_step_size < 0.01*step_size_avg):
            if verbose:
                print 'resetting step size from {} to {}'.format(
                    new_step_size, step_size_avg)
            new_step_size = step_size_avg
    LineSearchOutput = namedtuple('LineSearchOutput', \
    'new_step_size, step_size_avg, y_tt, dy_tt, x_tt, var_f_tt, var_df_tt')
    output = LineSearchOutput(new_step_size, step_size_avg, y_tt, dy_tt, \
                        x_tt, var_f_tt, var_df_tt, verbose)
    return output

def prob_wolfe_conditions(t, gp):
    # constants for Wolfe conditions (must be chosen 0 < c1 < c2 < 1)
    c1 = 0.05
    c2 = 0.8
    # c2 = 0 extends until ascend location reached: lots of extrapolation
    # c2 = 1 accepts any point of increased gradient: almost no extrapolation
    
    # belief at starting point
    m0 = gp.m_fun(0)
    dm0 = gp.d1m_fun(0)
    v0 = gp.v_fun(0)
    vd0 = gp.vd_fun(0)
    dvd0 = gp.dvd_fun(0)

    # marginal for Armijo condition
    ma = m0 - gp.m_fun(t) + c1 * t * dm0
    vaa = v0 + (c1 * t)**2 * dvd0 + gp.v_fun(t) + \
        2 * (c1 * t * (vd0 - gp.vd0f_fun(t)) - gp.v0f_fun(t))
        
    # marginal for curvature condition
    mb = gp.d1m_fun(t) - c2 * dm0
    vbb = c2^2 * dvd0 - 2 * c2 * gp.vd0f_fun(t) + gp.dvd_fun(t)
    
    # covariance between conditions
    vab = -c2 * (vd0 + c1 * t * dvd0) + gp.vd0f_fun(t) + \
        c2 * gp.vd0f_fun(t) + c1 * t * gp.vd0f_fun(t) - gp.vd_fun(t)
        
    if (vaa < 1e-9) and (vbb < 1e-9):  # deterministic evaluations
        p = (ma >= 0) * (mb > 0)
        return p
        
    # joint probability
    rho = vab / np.sqrt(vaa * vbb)
    if (vaa <= 0) or (vbb <= 0):
        return 0
    
    upper = 2 * c2 * ((abs(dm0) + 2 * np.sqrt(dvd0) - mb) / np.sqrt(vbb))
    p = bivariate_normal_integral.bvn(-ma / np.sqrt(vaa), np.inf, -mb / np.sqrt(vbb), upper, rho)
    return p
    

def cubic_minimum(ts, gp):
    '''Return minimum of cubic polynomial of mu(t) in region tv[i-1],tv[i].
    
    The polynomial has at most one minimum, found by solving a quadratic.
    
    Args:
        ts: current t value
        gp: gaussian process, containing posterior mean mu(t)
        
    Returns:
        minimum t value, or inf if none exists.
    '''    
    d1mt = gp.d1m_fun(ts)
    d2mt = gp.d2m_fun(ts)
    d3mt = gp.d3m_fun(ts)
    
    a = 0.5 * d3mt
    b = d2mt - ts * d3mt
    c = d1mt - d2mt * ts + 0.5 * d3mt * ts^2
    
    if abs(d3mt) < 1e-9:  # quadratic shape, single extremum
        return -(d1mt - ts * d2mt) / d2mt
        
    # compute the two possible roots
    det = b^2 - 4 * a * c
    if (det < 0):  # no roots
        return np.inf
    left_root = (-b - np.sign(a) * np.sqrt(det)) / (2*a)
    right_root = (-b + np.sign(a) * np.sqrt(det)) / (2*a)
    
    # compute the cubic function at these two points
    left_delta = left_root - ts  
    right_delta = right_root - ts
    left_cubic_val = d1mt * left_delta + 0.5 * d2mt * left_delta**2 + \
        d3mt * left_delta**3 / 6
    right_cubic_val = d1mt * right_delta + 0.5 * d2mt * right_delta**2 + \
        d3mt * right_delta**3 / 6
        
    if left_cubic_val < right_cubic_val:
        return left_cubic_val
    else:
        return right_cubic_val
    

# helper functions 
def gauss_cdf(z):
    return 0.5 * (1 + np.erf(z / np.sqrt(2)))


def gauss_pdf(z):
    return np.exp(-0.5 * np.square(z)) / np.sqrt(2*np.pi)

        
def expected_improvement(m, s, eta):
    """Implements eqn 9. of their paper.
    
    Args:
        m: mean
        s: standard deviation
        eta: current best value
    
    Returns:
        expected amount by which we might improve upon eta
    """
    scaled = (eta - m) / s
    return (eta - m) * gauss_cdf(scaled) + s * gauss_pdf(scaled) 