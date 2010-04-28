function z = round2(x,y)
%ROUND2 rounds number to nearest multiple of arbitrary precision.
%   Z = ROUND2(X,Y) rounds X to nearest multiple of Y.
%
%Example 1: round PI to 2 decimal places
%   >> round2(pi,0.01)
%   ans =
%         3.14
%
%Example 2: round PI to 4 decimal places
%   >> round2(pi,1e-4)
%   ans =
%         3.1416
%
%Example 3: round PI to 8-bit fraction
%   >> round2(pi,2^-8)
%   ans =
%         3.1406
%
%Examples 4-6: round PI to other multiples
%   >> round2(pi,0.05)
%   ans =
%         3.15
%   >> round2(pi,2)
%   ans =
%         4
%   >> round2(pi,5)
%   ans =
%         5 
%
% See also ROUND.
%author Robert Bemis
%url http://www.mathworks.com/matlabcentral/fileexchange/4261

%% defensive programming
error(nargchk(2,2,nargin))
error(nargoutchk(0,1,nargout))
if prod(size(y))>1
  error('n must be scalar')
end

%%
z = round(x/y)*y;

end