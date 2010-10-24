function xx = degexpand(x, deg, addOnes)
% Expand input vectors to contain powers of the input features

% This file is from pmtk3.googlecode.com


[n,m] = size(x);
if nargin < 3, addOnes = 0; end

xx = repmat(x, [1 1 deg]);
degs = repmat(reshape(1:deg, [1 1 deg]), [n m]);
xx = xx .^ degs;
xx = reshape(xx, [n, m*deg]);

if addOnes
  xx = [ones(n,1) xx];
end


% Scale down to numbers in [-1,1]
%  xx = xx / diag(max(abs(xx))) ;

% eg $x(n,1:p)$ goes to
%[x(n,1:p) \;\; x(n,1:p).^2 \; \ldots \; x(n,1:p).^d]

%x = [1 2 3; 
%     2 0.5 1.5;
%     0 1 2];
%degexpand(x, 2)
%ans =
%    1.0000    2.0000    3.0000    1.0000    4.0000    9.0000
%    2.0000    0.5000    1.5000    4.0000    0.2500    2.2500
%         0    1.0000    2.0000         0    1.0000    4.0000


end
