function [idx, val] = maxidx(varargin)
%% Return the linear index of the maximum value
% Same as built in max but with the order of the outputs reversed.

[val,idx] = max(varargin{:});
end