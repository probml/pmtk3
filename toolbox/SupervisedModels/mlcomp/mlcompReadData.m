function [X, y, comments] = mlcompReadData(fpath)
% Convert an mlcomp data file to matlab format.

% This file is from pmtk3.googlecode.com



raw = cellfun(@strtrim, getText(fpath), 'UniformOutput', false);
iscomment = cellfun(@(s)s(1) == '#', raw);
comments = raw(iscomment);
data  = raw(~iscomment);
ragged = cellfun(@(c)str2num(strrep(c, ':', ' ')), data, 'UniformOutput', false);

n = numel(ragged);
d = max(cellfun(@(c)c(end-1), ragged, 'ErrorHandler', @(varargin)0));
X = zeros(n, d);
y = zeros(n, 1);
for i=1:n
    row = ragged{i};
    y(i) = row(1);
    X(i, row(2:2:end)) = row(3:2:end);
end
end
