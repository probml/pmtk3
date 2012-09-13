function CPD = noisyOrCpdCreate(leakI, parentsI)
%% Create a noisy OR CPD
%
%(from BNT)
% A noisy-or node turns on if any of its parents are on, provided they are
% not inhibited. The prob. that the i'th parent gets inhibited (flipped
% from 1 to 0) is parentsI(i). The prob that the leak node (a dummy parent
% that is always on) gets inhibit is leakI. 
%
% Example: suppose C has parents A and B, and the
% link of A->C fails with prob pA and the link B->C fails with pB.
% Then the noisy-OR gate defines the following distribution
%
%  A  B  P(C=0)
%  0  0  1.0
%  1  0  pA
%  0  1  pB
%  1  1  pA * PB
%%

% This file is from pmtk3.googlecode.com

error('not finished')
CPD = structure(leakI, parentsI); 
CPD.nstates = 2; 
CPD.cpdType = 'noisyOr';
end
