function X = gibbsSample(fullCondSampler, xinit, Nsamples, Nburnin, thin)
%% Generic gibbs sampler
% fullCondSampler{i}(xh) returns a single sample for ith hidden variable,
% from the full conditional, (i.e. the distribution conditioned on all
% variables except the ith hidden), and with xh used as the values for the
% remaining initially hidden vars.
%
% OUTPUT
% X(s, :) = sample s, for s=1:Nsamples (every thin'th sample after burnin)

% This file is from pmtk3.googlecode.com


if nargin < 4, Nburnin = 0; end
if nargin < 5, thin = 1; end

keep = 1;
x = xinit;
S = (Nsamples*thin + Nburnin);
d = length(x);
X = zeros(Nsamples, d);
for iter=1:S
    for i=1:length(x)
        x(i) = fullCondSampler{i}(x);
    end
    if (iter > Nburnin) && (mod(iter, thin)==0)
        X(keep, :) = x; keep = keep + 1;
    end
end
end
