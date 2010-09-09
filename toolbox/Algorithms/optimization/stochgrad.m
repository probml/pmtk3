function [w, f, exitflag, output] = stochgrad(objFun, w0, options, X, y, varargin)
% This is a wrapper on stochgradSimple 
% It calls it multiple times to determine a good learning rate
% This doesn't seem to work, in the sense that changing t0 makes
% no visible difference...

% This file is from pmtk3.googlecode.com


[N,D] = size(X);
% Try several values of t0 on small subset of data
t0s = [1,  100, 10000];
ndx = 1:min(N, 500);
Xsmall = X(ndx,:); ysmall = y(ndx);
%finit = objFun(w0, Xsmall, ysmall, varargin{:});
for i=1:length(t0s)
  opt = options;
  opt.t0 = t0s(i);
  opt.maxepoch = 2;
  %opt.batchsize = numel(ndx);
  [w{i}, f, exitflag, output] = stochgradSimple(objFun, w0, opt, Xsmall, ysmall, varargin{:});
  ffinal(i) = objFun(w0, Xsmall, ysmall, varargin{:});
  %figure;plot(output.trace.stepSize, 'o-'); title(sprintf('t0=%d',opt.t0));
end
bestNdx = argmin(ffinal);
t0 = t0s(bestNdx);

% Now optimize over all data
opt = options;
opt.t0 = t0;
[w, f, exitflag, output] = stochgradSimple(objFun, w{bestNdx}, opt, X, y, varargin{:});


end
