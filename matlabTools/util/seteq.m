function eq = seteq(varargin)
% seteq(s1, s2, s3, ...) Returns true if s1=s2=s3 
% The elements of s{i} are sorted first.

% This file is from pmtk3.googlecode.com


S1 = rowvec(sort(varargin{1})); 
eq = true; 
for i=2:nargin
   Si = varargin{i}; 
   eq = eq && isequal(S1, rowvec(sort(Si))); 
   if ~eq, return; end 
end
end

