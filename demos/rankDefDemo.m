%% Rank Deficiency Demo
% Based on Moler Sec 5-7 p15
%
%%

% This file is from pmtk3.googlecode.com

X = reshape(1:15, [3 5])';
y = (16:20)';
w = X\y
norm(X*w - y)

w = [0,-15,15.3333]';
norm(X*w - y)

z =[1;-2;1];
c = rand; 
assert(approxeq(norm(X*(w+c*z) - y), 0))


w2 = pinv(X)*y
r2 = norm(X*w2 - y)

[norm(w) norm(w2)]
