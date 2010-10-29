function [samples, naccept] = metropolisHastings(target, proposal, xinit, Nsamples,  proposalProb)
% Metropolis-Hastings algorithm
%
% Inputs
% target returns the unnormalized log posterior, called as 'p = exp(target(x))'
% proposal is a fn, called as 'xprime = proposal(x)' where x is a 1xd vector
% xinit is a 1xd vector specifying the initial state
% Nsamples - total number of samples to draw
% proposalProb  - optional fn, called as 'p = proposalProb(x,xprime)',
%   computes q(xprime|x). Not needed for symmetric proposals (Metropolis algorithm)
%
% Outputs
% samples(s,:) is the s'th sample (of size d)
% naccept = number of accepted moves

% This file is from pmtk3.googlecode.com

if nargin < 5, proposalProb = []; end

d = length(xinit);
samples = zeros(Nsamples, d);
x = xinit(:)';
naccept = 0;
logpOld = target(x);
for t=1:Nsamples
  xprime = proposal(x);
  logpNew = target(xprime);
  alpha = exp(logpNew - logpOld);
  if ~isempty(proposalProb) % Hastings correction for asymmetric proposals
    qnumer = proposalProb(x, xprime); % q(x|x')
    qdenom = proposalProb(xprime, x); % q(x'|x)
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
