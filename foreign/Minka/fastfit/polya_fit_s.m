function a = polya_fit_s(data, a, weight)
% POLYA_FIT_S   Maximum-likelihood Dirichlet-multinomial (Polya) precision.
%
% POLYA_FIT_S(data,a) returns the MLE (a) for the matrix DATA,
% subject to a constraint on A/sum(A).
% Each row of DATA is a histogram of counts.
% A is a row vector providing the initial guess for the parameters.
%
% POLYA_FIT_S(data,a,weight) returns the MLE where each histogram is weighted.
% WEIGHT is a column vector of numbers in [0,1] (default all ones).
%
% A is decomposed into S*M, where M is a vector such that sum(M)=1,
% and only S is changed by this function.  In other words, A/sum(A)
% is unchanged by this function.
%
% The algorithm is a generalized Newton iteration, described in
% "Estimating a Dirichlet distribution" by T. Minka.

% Written by Tom Minka

show_progress = 0;

s = sum(a);
m = a/s;

row = (rows(a) == 1);
if row
  sdata = row_sum(data);
else
  [K,N] = size(data);
  sdata = col_sum(data);
end

use_weight = (nargin > 2);

e = [];
% generalized Newton algorithm
for iter = 1:10
  old_s = s;
  if row
    if use_weight
      [g,h,c1,c3] = s_derivatives(a, data, sdata, weight);
    else
      [g,h,c1,c3] = s_derivatives(a, data, sdata);
    end
  else
    if use_weight
      [g,h,c1,c3] = s_derivatives(a, data', sdata', weight');
    else
      [g,h,c1,c3] = s_derivatives(a, data', sdata');
    end
  end      
  if g > eps
    r = g + s.*h;
    if r >= 0
      % the maximum is infinity
      s = Inf;
    else
      s = s./(1 + g./h./s);
    end
  end
  if g < -eps & c1 > eps
    s = special_case(s, g, h, c1, c3);
  end  
  a = s*m;
  if show_progress
    p = polya_logProb(a, data);
    if use_weight
      p = p.*weight;
    end
    e(iter) = sum(p);
  end
  if show_progress & rem(iter,10) == 0
    plot(e)
    drawnow
  end
  if ~finite(s) | abs(s - old_s) < 1e-6
    break
  end
end
if show_progress 
  plot(e)
end
%e(iter)
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function s = special_case(s, g, h, c1, c3)

a1 = h.*s.^2 + c1;
a2 = 2*s.^2.*(h.*s + g);
a3 = s.^3.*(2*g + h.*s);
if abs(2*g + h.*s) < 1e-13
  a3 = c3;
end
b = quad_roots(a1, a2, a3);
a = (g./c1).*((s+b)./b).^2;
% 1/s = 1/s - a
s = 1./(1./s - a);
end