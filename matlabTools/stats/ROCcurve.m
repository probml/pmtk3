function [faRate, hitRate, AUC] = ROCcurve(score, trueLabel, doPlot)
% Plot a receiver operating curve
% function [faRate, hitRate, AUC] = plotROCcurve(score, trueLabel, doPlot)
%
% score(i) = confidence in i'th detection (bigger means more confident)
% trueLabel(i) = 0 if background or 1 if target
% doPlot - optional (default 1)
%
% faRate(t) = false alarm rate at t'th threshold
% hitRate(t) = detection rate at t'th threshold 
% AUC = area under curve

% This file is from pmtk3.googlecode.com


if nargin < 3, doPlot = 0; end

class1 = find(trueLabel==1);
class0 = find(trueLabel==0);

thresh = unique(sort(score));
Nthresh = length(thresh);
hitRate = zeros(1, Nthresh); 
faRate = zeros(1, Nthresh);
for thi=1:length(thresh)
  th = thresh(thi);
  % hit rate = TP/P
  hitRate(thi) = sum(score(class1) >= th) / length(class1);
  % fa rate = FP/N
  faRate(thi) = sum(score(class0) >= th) / length(class0);
end
AUC = sum(abs(faRate(2:end) - faRate(1:end-1)) .* hitRate(2:end));

if ~doPlot, return; end

plot(faRate, hitRate, '-');
e = 0.05; axis([0-e 1+e 0-e 1+e])
xlabel('false alarm rate')
ylabel('hit rate')
grid on
title(sprintf('AUC=%5.3f', AUC))

end
