function [idx, val] = minidx(varargin)
% Return the linear index of the minimum value
% Same as built in min but with the order of the outputs reversed.     
   [val,idx] = min(varargin{:}); 
end