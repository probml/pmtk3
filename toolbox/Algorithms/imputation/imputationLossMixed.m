function loss = imputationLossMixed( Xtrue, Ximpute, missVal, types )
% Combined Euclidean/ Hamming loss when comparing matrices of mixed type
% type(j) = 'c' or 'd' for continuous or discrete (categorical)

% This file is from pmtk3.googlecode.com


%PMTKauthor Hannes Bretschneider

[N D] = size(Xtrue);
iscont = (types=='c');
isdiscr = ~iscont;
% My solution to the problem of making the loss in the continuous and
% discrete features comparable was to standardize the continuous features
% and use the euclidean distance on them (with sqrt). Therefore one
% std-deviation <=> one unit loss.
[XtrueC mu] = centerCols(Xtrue(:,iscont));
[XtrueC sd] = mkUnitVariance(XtrueC);
XimputeC = centerCols(Ximpute(:,iscont),mu);
XimputeC = mkUnitVariance(XimputeC, sd);
missValC = missVal(:,iscont);
XtrueD = Xtrue(:,isdiscr);
XimputeD = Ximpute(:,isdiscr);
missValD = missVal(:,isdiscr);

loss = zeros(N,D);
loss(missValC) = sqrt((XtrueC(missValC)-XimputeC(missValC)).^2);
loss(missValD) = (XtrueD(missValD)~=XimputeD(missValD));
loss = sum(sum(loss,2)/D)/N;
end

