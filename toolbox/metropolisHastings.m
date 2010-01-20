function [X, acceptRatio] = metropolisHastings(target, proposal, xinit, Nsamples, Nburnin, thin)
% Metropolis Hastings algorithm
%
% target - logp = target(x)
% proposal -  xprime = proposal(x) or  [xprime, probOldToNew, probNewToOld]= proposal(x)
% xinit - a dx1 row vector
% Nsamples
% Optional arguments
% Nburnin [0]
% thin - take every n'th sample [n=1]
%
% OUTPUT
% X(s,:) = samples at step s
%
% If the proposal is not symmetric, it should be of the form
% [ xprime, probOldToNew, probNewToOld]= proposal(x)
% so  we use the Hastings correction

if nargin < 5, Nburnin = 0; end
if nargin < 6, thin = false; end
symmetric = (nargout(proposal)==1 || nargout(proposal) == -1); % -1 indicates variable output args or anonymous function


keep = 1;
x = xinit;
logpx = target(x);
S = (Nsamples*thin + Nburnin);
d = length(x);
X = zeros(Nsamples, d);
u = rand(S,1); % move outside main loop to speedup MH
naccept = 0;
for iter=1:S
  [x, accept, logpx] = mhUpdate(x, logpx, u(iter), proposal, target, symmetric); 
  if (iter > Nburnin) && (mod(iter, thin)==0)
    X(keep,:) = x; keep = keep + 1;
    naccept = naccept + accept;
  end
end
acceptRatio = naccept/(keep-1);
end


function [xnew, accept, logpNew] = mhUpdate(x, logpOld, u, proposal, target, symmetric)
if symmetric
  [xprime] = proposal(x);
  probOldToNew = 1; probNewToOld = 1;
else
  [xprime, probOldToNew, probNewToOld] = proposal(x);
end
logpNew = target(xprime); 
alpha = exp(logpNew - logpOld);
alpha = alpha * (probNewToOld/probOldToNew);  % Hastings correction for asymmetric proposals
r = min(1, alpha);
%u = rand(1,1);
if u < r
  xnew = xprime;
  accept = 1;
else
  accept = 0;
  xnew = x;
  logpNew = logpOld;
end
end
    