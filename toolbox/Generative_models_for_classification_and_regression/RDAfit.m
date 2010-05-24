function [ model ] = RDAfit(X, y, gamma, varargin)
% Fit regularized discriminant analysis

%PMTKauthor Hannes Bretschneider

[R, V] = process_options(varargin, 'R', [], 'V', []);

if isempty(R)||isempty(V)
    [U S V] = svd(X, 'econ');
    R = U*S;
end

% This allows any kind of labels, e.g. text labels or ones that are not
% consecutively numbered
[N D] = size(X);
activeGroups = unique(y);
numGroups = length(activeGroups);
for i=1:length(activeGroups)
    y(y == activeGroups(i)) = i;
end
nGroups = arrayfun(@(g)sum(y==g),1:numGroups);
model.size = [N numGroups];
model.classPrior = nGroups/N;

Rcov = cov(R);
Sreg = (gamma*Rcov+(1-gamma)*diag(diag(Rcov)));
Sinv = inv(Sreg);

for k=1:numGroups
    model.mu{k} =  mean(X(y==k,:))';
    muRed = mean(R(y==k,:))';
    model.beta{k} =  V*Sinv*muRed;
end

