function [s_opt, b_opt, res_mean, res_std] = crossvalidate(fun, K, steps, X, y, varargin)
% CROSSVALIDATE  Perform K-fold cross validation on a function.
%    [S_OPT, B_OBT, RES_MEAN, RES_STD] = CROSSVALIDATE(FUN, K, STEPS, X, Y,
%    ...) performs simple K-fold cross validation on function FUN. STEPS is
%    the number of equidistant positions along FUN at which the sum of
%    squared residuals (SSR) is measured. Typically this is some large
%    number to ensure sufficent accuracy. X is the data matrix used as
%    input to FUN together with the response Y.  Finally, an arbitrary
%    number of arguments may be supplied to FUN.
%
%    Returns 0 < S_OPT <= 1 that determines the optimal model position,
%    B_OPT - the optimal parameters, RES_MEAN - the mean SSR curve and
%    RES_STD - the standard deviations of the SSR curve.
%
%    Note: This is merely a simple implementation that has been tested with
%    the LARS and LARSEN function only. Use cautiously.
%




%% Check varargin with fun
fun = fcnchk(fun,length(varargin));

%% Perform K-fold cross-validation
[n p] = size(X);
% rp = randperm(n);
rp = 1:n;
kappa = floor(n/K);
step = 1/(steps - 1);
b_interpolated = zeros(steps, p);
res = zeros(K, steps);
for k = 1:K
  testidx = rp((k-1)*kappa + 1:k*kappa);
  validx = setdiff(rp(1:K*kappa), testidx);
  Xtest = X(testidx,:);
  ytest = y(testidx);
  Xval = X(validx, :);
  yval = y(validx);
  if isempty(yval)
    Xval = Xtest;
    yval = ytest;
  end
  b = fun(Xval, yval, varargin{:});
  t = sum(abs(b),2);
  s = (t - min(t))/max(t - min(t));
  [sm s_idx] = unique(s, 'rows');
  b_interpolated = interp1q(s(s_idx), b(s_idx, :), (0:step:1)');
  res(k, :) = sum((ytest*ones(1,steps) - Xtest*b_interpolated').^2);
end

%% Find optimal index in residual vector
% Calculate mean residual curve
if size(res,1) > 1
  res_mean = mean(res);
  res_std = std(res);
else
  res_mean = res;
  res_std = zeros(size(res));
end
% Find optimal index
[res_min idx_opt] = min(res_mean);
limit = res_min + res_std(idx_opt);
idx_opt2 = find(res_mean < limit, 1);
if ~isempty(idx_opt2)
  idx_opt = idx_opt2;
end

%% Find optimal coefficient vector
s_opt = idx_opt/steps;
b = fun(X, y, varargin{:});
t = sum(abs(b),2);
s = (t - min(t))/max(t - min(t));
[sm s_idx] = unique(s, 'rows');
b_opt = interp1q(s(s_idx), b(s_idx, :), s_opt);


end