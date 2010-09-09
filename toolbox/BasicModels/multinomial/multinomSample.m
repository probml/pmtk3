function S = multinomSample(arg1, arg2, arg3)
%% S(1:nsamples, :) ~ Mu(N, p)
% S = multinomSample(model, nSample); OR S = multinomSample(N, p, nSamples);
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
%
%%

% This file is from pmtk3.googlecode.com

if isstruct(arg1)
    model = arg1;
    N = model.N;
    p = model.p;
    if nargin < 2
        nSamples = 1;
    else
        nSamples = arg2;
    end
else
    N = arg1;
    p = arg2;
    if nargin < 3
        nSamples = 1;
    else
        nSamples = arg3;
    end
end

S = histc(rand(nSamples, N), [0, cumsum(p(:)')], 2);
S(:, end) = [];
end
