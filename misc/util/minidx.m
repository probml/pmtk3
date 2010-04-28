function [idx,val] = minidx(varargin)
% same as built in min but with the order of the outputs reversed.     
   [val,idx] = min(varargin{:}); 
end