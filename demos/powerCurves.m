%% Power vs sample size for excluding a null value from binary trials
% Based on p337 of "Doing Bayesian Data Analysis" Kruschke 2010

function power = powerCurves(priorMean, priorN, nullValue, maxWidth, Ns)

if nargin < 3, nullValue = []; end
if nargin < 4, maxWidth = []; end
if nargin < 5, Ns = 1:5:100; end

prior.a = priorMean*priorN;
prior.b = (1-priorMean)*priorN;
uniformPrior.a = 1;
uniformPrior.b = 1;
for Ni=1:numel(Ns)
  N = Ns(Ni);
  xs = 0:N;
  for i=1:numel(xs)
    x = xs(i);
    px(i) = exp(nchoosekln(N,x) + betaln(x+prior.a, N-x+prior.b) ...
      - betaln(prior.a, prior.b));
    postA = uniformPrior.a + x; 
    postB = uniformPrior.b + N-x;
    icdf = @(p) betainv(p, postA, postB);
    H = hdiFromIcdf(icdf);
    if ~isempty(nullValue)
      goal(i) = (H(1) > nullValue) || (H(2) < nullValue);
    end
    if ~isempty(maxWidth)
      goal(i) = H(2)-H(1) <= maxWidth;
    end
  end
  power(Ni) = sum(px .* goal);
end
end
