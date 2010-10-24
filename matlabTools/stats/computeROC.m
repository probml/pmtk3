function [FPrate, TPrate, AUC, thresholds] = computeROC(confidence, testClass)
%% Compute ROC curve statistics
%
% Inputs: 
%  confidence(i) is proportional to the probability that  testClass(i) is positive
%  testClass(i) = 0 => target absent, testClass(i) = 1 => target present
%
% Outputs:
% FPrate(i) = False positive rate at threshold i
% TPrate(i) = True positive rate at threshold i
% AUC = area under curve
% thresholds(i) = thresholds used
%
% Based on algorithms 2 and 4 from Tom Fawcett's paper "ROC Graphs: Notes and
% Practical Considerations for Data Mining Researchers" (2003)
% http://www.hpl.hp.com/techreports/2003/HPL-2003-4.pdf"
%
%PMTKdate February 21, 2005
%PMTKauthor Vlad Magdin
% UBC

% This file is from pmtk3.googlecode.com


% break ties in scores
S = rand('state');
rand('state',0); 
confidence = confidence + rand(size(confidence))*10^(-10);
rand('state',S)
[thresholds order] = sort(confidence, 'descend');
testClass = testClass(order);

%%% -- calculate TP/FP rates and totals -- %%%
AUC = 0;
faCnt = 0;
tpCnt = 0;
falseAlarms = zeros(1,size(thresholds,2));
detections = zeros(1,size(thresholds,2));
fPrev = -inf;
faPrev = 0;
tpPrev = 0;

P = max(size(find(testClass==1)));
N = max(size(find(testClass==0)));

for i=1:length(thresholds)
    if thresholds(i) ~= fPrev
        falseAlarms(i) = faCnt;
        detections(i) = tpCnt;

        AUC = AUC + polyarea([faPrev faPrev faCnt/N faCnt/N],[0 tpPrev tpCnt/P 0]);

        fPrev = thresholds(i);
        faPrev = faCnt/N;
        tpPrev = tpCnt/P;
    end
    
    if testClass(i) == 1
        tpCnt = tpCnt + 1;
    else
        faCnt = faCnt + 1;
    end
end

AUC = AUC + polyarea([faPrev faPrev 1 1],[0 tpPrev 1 0]);

FPrate = falseAlarms/N;
TPrate = detections/P;
