function [X, mu, mode] = meanValueImputation(Xmiss, type)
% Compute mean (or mode for discrete) of each column
% and use it to fill in NaN entries in Xmiss (size N*D)
% type(j) = 'c' for continuous or 'd' for discrete
%
% Example
% Xmiss = [1 2 3 1 NaN 4 NaN]'
% meanValueImputation(Xmiss, 'd') % [1 2 3 1 1 4 1]
% meanValueImputation(Xmiss, 'c') % [1 2 3 1 2.2 4 2.2]

% This file is from pmtk3.googlecode.com



[N, D] = size(Xmiss);
if nargin < 2, type = repmat('c', 1, D); end
dataMissing = isnan(Xmiss);
missingRows = any(dataMissing,2);

X = Xmiss;

mu = zeros(1,D);
ndxC = find(type=='c');
for ji=1:length(ndxC)
    j = ndxC(ji);
    mu(j) = nanmeanPMTK(Xmiss(:, j));
    X(missingRows,j) = mu(j);
end

mode = zeros(1,D);
ndxD = find(type=='d');
for ji=1:length(ndxD)
    j = ndxD(ji);
    support = unique(Xmiss(:, j));
    counts = hist(Xmiss(:,j), support);
    [junk, mode(j)] = max(counts);
    X(missingRows, j) = mode(j);
end
