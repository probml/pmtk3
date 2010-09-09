function model = mkRndGaussHmm(nstates, d)
%% Make a random HMM model with a Gaussian emission distribution
% nstates is the number of hidden states
% d is the observation dimensionality
%%

% This file is from pmtk3.googlecode.com

if nargin < 1
    nstates = 4;
end
if nargin < 2
    d = 8;
end
A     = normalize(rand(nstates), 2);
pi    = normalize(rand(nstates, 1));
Sigma = zeros(d, d, nstates);
for k=1:nstates
    Sigma(:, :, k) = randpd(d) + 2*eye(d);
end
emission = condGaussCpdCreate(randn(d, nstates), Sigma);
model = hmmCreate('gauss', pi, A, emission);
end


