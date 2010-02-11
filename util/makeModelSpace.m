function models = makeModelSpace(varargin)
% Helper function to prepare the model space for model selection. 
% Pass in one argument per dimension. Returns a cell array of every
% combination of values. 
%
% Example:
% 
% lambdaRange = logspace(0, 100, 10); 
% sigmaRange  = linspace(0, 10, 10);
%
% allCombinations = makeModelSpace(lambdaRange, sigmaRange
%
%

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
