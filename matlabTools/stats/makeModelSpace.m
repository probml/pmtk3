function models = makeModelSpace(varargin)
% Return a cell array of every combination of the inputs
% Pass in one argument per dimension. Returns a cell array of every
% combination of values.
%
% Example:
%
% lambdaRange = logspace(0, 100, 10);
% sigmaRange  = linspace(0, 10, 10);
%
% allCombinations = makeModelSpace(lambdaRange, sigmaRange)
%
% Supports more than 2 dimensions, i.e. makeModelSpace(1:3, 2:4, 7:9, 2:3)
%%

% This file is from pmtk3.googlecode.com

if(nargin == 1)
    space = varargin{1}';
else
    space = gridSpace(varargin{:});
end
models = cell(size(space,1),1);
for i=1:size(space,1)
    models{i} = num2cell(space(i,:));
end
end
