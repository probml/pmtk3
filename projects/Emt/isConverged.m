function [converged, diff] = isConverged(val, tol, mode)
%
% [converged, diff] = isConverged(val, tol, mode)
%
% Access convergence for a monotonically increasing objective Function (or a
% vector of parameters). Mode needs to be 'objFun' for the former and
% 'parameter' for the later.
% Val contains the value of objective function till the current iteration,
% tol is the tolerance to access convergence.
%
% For a decreasing function, pass -val instead of val.
%
% Written by Emt, CS, UBC, April 5, 2009

% in case given as parameter vector vs iteration
[d,iters] = size(val);
if iters ==1
  converged = 0;
  diff = NaN;
  return;
end

switch mode
  case 'objFun'
    % case of a monotonic objective function
    % compare the difference between the last and the second last value
    valOld = val(end-1);
    valCurr = val(end);
    diff = (valCurr- valOld);%/abs(valOld);
  case 'parameter'
    % case of a parameter vector
    % compare the difference between the last and the second last value
    valOld = val(:,end-1);
    valCurr = val(:,end);
    diff = (valOld- valCurr);
    diff = diff'*diff/length(diff);
end

if abs(diff) < tol
  converged = 1;
else
  converged = 0;
end



