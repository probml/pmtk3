function [L, Lij] = discreteLogprobMissingData(model, X)
% Same as discreteLogprob, except X may have NaNs

%PMTKauthor Kevin Murphy

d = model.d;
X = reshape(X, [], d); 
n = size(X, 1);
T = model.T;
Lij = zeros(n, d);
 
missingRows = any(isnan(X), 2);
[Lv, Lij(~missingRows,:)] =  discreteLogprobMissingData(model, X(~missingRows)); %#ok
for i=missingRows(:)'
  vis = ~isnan(X(i,:));
  for j=vis
    Lij(i, j) = log(T(X(i, j), j)+eps);
  end
end
L = sum(Lij, 2);
end