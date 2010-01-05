gammaln(0.1) - 2.2527126517342059598697
gammaln(0.6) - .39823385806923489961685
gammaln(0.7) - .26086724653166651438573
gammaln(1.0)
gammaln(2.0)
gammaln(3.4) - 1.0923280598027415674947
gammaln(4.0) - 1.791759469228055000812477
gammaln(8.0) - 8.525161361065414300165531
gammaln(64.0) - 201.00931639928152667928
gammaln(256.0) - 1161.71210111840065079
if gammaln(0) ~= Inf
  error('gammaln(0) should be Inf');
end
if ~isnan(gammaln(-1))
  error('gammaln(-1) should be NaN');
end
if gammaln(Inf) ~= Inf
  error('gammaln(Inf) should be Inf');
end
% should be NaN?
gammaln(-Inf)
if ~isnan(gammaln(NaN))
  error('gammaln(NaN) should be NaN');
end
