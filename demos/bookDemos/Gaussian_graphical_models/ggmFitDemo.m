%% Example of finding the MLE precision matrix for a GGM
% HTF 2e p634
%%

% This file is from pmtk3.googlecode.com

G = zeros(4,4);
G(1,[2 4]) = 1;
G(2,[3 1]) = 1;
G(3,[2 4]) = 1;
G(4,[1 3]) = 1;

S = [10 1 5 4;
     1 10 2 6;
     5 2 10 3;
     4 6 3 10];
%%
precMat = ggmFitHtf(S, G); 
Sigma   = inv(precMat);


assert(approxeq(Sigma, [10 1 1.31 4; 1 10 2 0.87; 1.31 2 10 3; 4 0.87 3 10]))
assert(approxeq(precMat, [0.12 -0.01 0 -0.05; -0.01 0.11 -0.02 0; 0 -0.02 0.11 -0.03; -0.05 0 -0.03 0.13]))
