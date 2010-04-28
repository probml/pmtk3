function [hamming, ACC1, FP, FN, TP, TN] = compareGraphs(obj, GhatObj)

Gtrue = obj.adjMat;
Ghat = GhatObj.adjMat;
edgesTrue = find(Gtrue>0);
edgesPred = find(Ghat>0);
nonedgesTrue = find(Gtrue==0);
nonedgesPred = find(Ghat==0);
TP = length(intersect(edgesTrue, edgesPred));
FP = length(setdiff(edgesPred, edgesTrue));
TN = length(intersect(nonedgesTrue, nonedgesPred));
FN = length(setdiff(nonedgesPred, nonedgesTrue));
SE = TP/(TP+FN);
SP = TN/(FP+TN);
ACC = (TP+TN)/(TP+TN+FP+FN);
ACC1 = 1-ACC;

hamming = sum(sum(triu(Gtrue) ~= triu(Ghat)));

end
