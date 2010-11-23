%% Simulation example from "a tale of three cousins: lasso, l2boosting, and dantzig"
% Meinshausen, Rocha and Yu
% [y w s X]=three_cousin(options) creates measurements y with weights w and
% selected variables s, and matrix X options has the following fields: n -
% number of measurements d - number of variables rho - correlation
% coefficients sigma2 - noise variance Written by Emt and Kevin
%%

% This file is from pmtk3.googlecode.com

function [y w s X]=makeData3cousins(options)
if nargin == 0, options = {}; end
[n,d,rho,sigma2,amp] = myProcessOptions(options,'n',40,'d',60,'rho',0.1,'sigma2',0.2,'amp',1);

%generates random matrix X of size nx10, 4 variables on
%Sigma = eye(n,n);
%for i = 1:n
%for j = 1:n
%  Sigma(i,j) = rho^abs(i-j);
%end
%end
%L = chol(Sigma);
%for i = 1:d
%  col = L*randn(n,1);
%  X(:,i) = col;%/norm(col);%normalize the column of X
%end

Sigma = eye(d,d);
for i = 1:d
  for j = 1:d
    Sigma(i,j) = rho^abs(i-j);
  end
end
L = chol(Sigma);
X = (L*randn(d,n))';

wstar = amp*[-0.65 -0.38 -0.37 -0.27 -0.12 -0.08 0.05 0.24 0.37 0.41]';
ind = [60 2 21 49 20 27 4 43 51 32]';
s = zeros(d,1);
s(ind) = 1;
w = zeros(d,1);
w(ind) = wstar;
%w = w/(sqrt(n)*norm(X*w));
%wstar = w(ind);

%generate measurements
y = X*w + sqrt(sigma2)*randn(n,1);



end
