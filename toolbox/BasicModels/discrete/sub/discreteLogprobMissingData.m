function [L, Lij] = discreteLogprobMissingData(arg1, X)
% Same as discreteLogprob, except X may have NaNs
%PMTKauthor Kevin Murphy

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    T = model.T;
    d = model.d;
else
    T = arg1;
    [K, d] = size(T);
end

X = reshape(X, [], d);
n = size(X, 1);
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
