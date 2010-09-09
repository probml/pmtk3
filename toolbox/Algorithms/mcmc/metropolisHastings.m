function [samples, naccept] = metropolisHastings(target, proposal, xinit, Nsamples, targetArgs, proposalArgs, proposalProb)
% Metropolis-Hastings algorithm
%
% Inputs
% target returns the unnormalized log posterior, called as 'p = exp(target(x, targetArgs{:}))'
% proposal is a fn, as 'xprime = proposal(x, proposalArgs{:})' where x is a 1xd vector
% xinit is a 1xd vector specifying the initial state
% Nsamples - total number of samples to draw
% targetArgs - cell array passed to target
% proposalArgs - cell array passed to proposal
% proposalProb  - optional fn, called as 'p = proposalProb(x,xprime, proposalArgs{:})',
%   computes q(xprime|x). Not needed for symmetric proposals (Metropolis algorithm)
%
% Outputs
% samples(s,:) is the s'th sample (of size d)
% naccept = number of accepted moves

% This file is from pmtk3.googlecode.com


if nargin < 5,  targetArgs = {}; end
if nargin < 6,  proposalArgs = {}; end
if nargin < 7, proposalProb = []; end

d = length(xinit);
samples = zeros(Nsamples, d);
x = xinit(:)';
naccept = 0;
logpOld = target(x, targetArgs{:});
for t=1:Nsamples
    xprime = proposal(x, proposalArgs{:});
    logpNew = target(xprime, targetArgs{:});
    alpha = exp(logpNew - logpOld);
    if ~isempty(proposalProb) % Hastings correction for asymmetric proposals
        qnumer = proposalProb(x, xprime, proposalArgs{:}); % q(x|x')
        qdenom = proposalProb(xprime, x, proposalArgs{:}); % q(x'|x)
        alpha = alpha * (qnumer/qdenom);
    end
    r = min(1, alpha);
    u = rand(1,1);
    if u < r
        x = xprime;
        naccept = naccept + 1;
        logpOld = logpNew;
    end
    samples(t,:) = x;
end

end
