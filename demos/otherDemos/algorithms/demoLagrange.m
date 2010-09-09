%% Lagrange Demo
%
%%

% This file is from pmtk3.googlecode.com

A = [1 1; 1 -1; -1 1; -1 -1];
H = 2*eye(2);
K = [H A'; A zeros(4)];
d = [3; 1/4];
b = ones(4,1);
xl = K \ [d;b]

KK=K(1:4,1:4)
xl2 = KK\[d;b(1:2)]

