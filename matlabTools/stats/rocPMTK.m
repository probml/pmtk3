function [AUC,  fpr, tpr,  EER, cutoff, tprAtThresh, fprAtThresh, thresh] = ...
  rocPMTK(confidence, testClass, fprThresh)
% Compute ROC curve
% confidence(i) is a real value
% label(i) is 0 or 1
%
% AUC is area under curve
% cutoff is the threshold that gives equal error rate (EER)
% EER is the fpr=tpr at cutoff
% fpr(t) is false positive rate for threshold t (x axis)
% tpr(t) is true positive rate for threshold t (y axis)

if nargin < 3, fprThresh = 0.1; end

ndxAbs = find(testClass<=0); % absent
ndxPres = find(testClass==1); % present

%[th, j] = sort(confidence(ndxAbs));
[th, j] = sort(confidence);
th = th(fix(linspace(1, length(th), 50))); 

cAbs = confidence(ndxAbs);
cPres = confidence(ndxPres);
for t=1:length(th)
  detectionRate(t)  = sum(cPres>=th(t)) / length(ndxPres);
  falseAlarmRate(t) = sum(cAbs>=th(t)) / length(ndxAbs);
end

fpr = falseAlarmRate;
tpr = detectionRate;
ndx = find(isnan(fpr)); fpr(ndx) = []; tpr(ndx) = [];
ndx = find(isnan(tpr)); fpr(ndx) = []; tpr(ndx) = [];

% Find the threshold that is closest to fprThresh
[~, ndx] = min(abs(fpr-fprThresh));
thresh = th(ndx);
fprAtThresh = fpr(ndx);
tprAtThresh = tpr(ndx);

AUC = -trapz(fpr, tpr); %estimate the area under the curve
%AUC2 = abs(sum((fpr(2:end)-fpr(1:end-1)).*(tpr(2:end) +tpr(1:end-1))/2));

%the best cut-off point is the closest point to (0,1)
% This trick is due to Giuseppe Cardillo
% Unfortunatelty it fails if the curve is not convex
%d=realsqrt(fpr.^2+(1-tpr).^2); %pythagoras's theorem
%[~,ndx]=min(d); %find the least distance
% Instead we will find the threshold where fpr = 1-tpr
delta = fpr - (1-tpr);
[~,ndx] = min(delta.^2);
cutoff =th(ndx); 
               
% performance at EER point
TP = sum( (confidence >= cutoff) & (testClass == 1) );
FN = sum( (confidence < cutoff) & (testClass == 1) );
FP = sum( (confidence >= cutoff) & (testClass == 0) );
TN = sum( (confidence < cutoff) & (testClass == 0) );
FPR = FP/(FP+TN);
%assert(FP+TN==sum(testClass==0)) % may fail if any(isnan(confidence))
EER = FPR;


end
