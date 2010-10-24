function [idx, val] = maxidx(varargin)
%% Return the linear index of the maximum value
% Same as built in max but with the order of the outputs reversed.

% This file is from pmtk3.googlecode.com


[val,idx] = max(varargin{:});
end
