function [idx,val] = maxidx(varargin)
% same as built in max but with the order of the outputs reversed.     
    
   [val,idx] = max(varargin{:}); 
end