%% Rank Deficiency Demo
% Based on Moler Sec 5.7 p15
% http://www.mathworks.com/moler/leastsquares.pdf
%%

% This file is from pmtk3.googlecode.com

X = reshape(1:15, [3 5])';
y = (16:20)';

% Solution produced by backslash
wqr = X\y
assert(approxeq(norm(X*wqr - y), 0))

% Another basic solution with same residual
w2 = [0,-15,15.3333]'; % 7.5*z + wqr
assert(approxeq(norm(X*w2 - y), 0))

% A null vector of X
z =[1;-2;1];
% Let us check that we can create an infinite number of solutions
c = rand; 
assert(approxeq(norm(X*(wqr + c*z) - y), 0))

% Pseudo inverse
wpinv = pinv(X)*y
assert(approxeq(norm(X*wpinv - y), 0))

% Pinv has smaller norm
[norm(wqr) norm(wpinv)]

%{
setSeed(0);
X = rand(100,20);
K = 10;
[U,S,V]=svd(X,'econ');
W = V(:,1:K);
Hhat = X*W;
Hhat2 = U(:,1:K) * S(1:K,1:K);
assert(approxeq(Hhat, Hhat2));
%}




