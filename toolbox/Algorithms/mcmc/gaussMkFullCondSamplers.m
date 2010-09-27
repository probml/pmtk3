function fcs = gaussMkFullCondSamplers(model, visVars, visVals)
% Returns a cell array of function handles 
% containing the full conditionals for an MVN
% for use by e.g. gibbs sampling.
%
% For instance, fcs{i}(xh), returns a single sample for ith hidden
% variable, from the full conditional, (i.e. the distribution conditioned
% on all variables except the ith hidden), and with xh used as the values
% for the remaining initially hidden vars.
%

% This file is from pmtk3.googlecode.com

d = length(model.mu);
if nargin < 2,
    % Sample from the unconditional distribution
    visVars = [];
    visVals = [];
end
V = visVars;
H = setdiffPMTK(1:d, V);
x = zeros(1, d);
x(V) = visVals;
fcs = cell(length(H), 1);
for i=1:length(H)
    fcs{i} = @(xh) gaussSample(fullCond(model, xh, i, H, x));
end
end

function p = fullCond(model, xh, i, H, x)
x(H) = xh; % insert sampled hidden values into hidden slot
x(i) = []; % remove value for i'th node, which will be sampled
d = length(model.mu);
dom = 1:d;
dom(i) = []; % specify that all nodes are observed except i
p = gaussCondition(model, dom, x);
end
