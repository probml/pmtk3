function S = multinomSample(model, nsamples)
%% S(1:nsamples, :) ~ Mu(model.N, model.p)
% model.p must sum to one
% sum(S(i, :)) = N for all i. 
% S is of size, nsamples-by-length(p), and S(i, j) is in {0, ... , N}
%% Example
%
% setSeed(0);
% model.N = 10;
% model.p = [0.3 0.5 0.2];
% nsamples = 5;
% S = multinomSample(model, nsamples)
% S =
%      2     7     1
%      3     7     0
%      1     6     3
%      1     6     3
%      3     6     1
%5
S = histc(rand(nsamples, model.N), [0, cumsum(model.p(:)')], 2);
S(:, end) = []; 
end