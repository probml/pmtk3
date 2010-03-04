function [X, y, comments] = mlcompReadData(fpath)
% Convert an mlcomp data file to matlab format.


raw = cellfun(@strtrim, getText(fpath), 'UniformOutput', false);
iscomment = cellfun(@(s)s(1) == '#', raw);
comments = raw(iscomment);
raw  = raw(~iscomment);
vals = cellfun(@(c)str2num(strrep(c, ':', ' ')), raw, 'UniformOutput', false);
n = numel(vals);
d = max(cellfun(@(c)c(end-1), vals, 'ErrorHandler', @(varargin)0));

X = zeros(n, d);
y = zeros(n, 1);
for i=1:n
    row = vals{i};
    y(i) = row(1);
    X(i, row(2:2:end)) = row(3:2:end);
end
end