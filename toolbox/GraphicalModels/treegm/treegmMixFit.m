function [model] = treegmMixFit(X, K)
% Fit a mixture of K trees
% X is N*D, rows are data cases, values in {1,..,R}
%
% model.mixWeights
% model.G{k} sparse adjacency matrix
% model.CPD{k}{i}(u,v) = p(i=v|pa(i)=u) for node i in tree k
%PMTKbroken

% This file is from pmtk3.googlecode.com

error('unfinished')

values = unique(unique(full(X)));
N = size(X,1); Maxiter = 30; 
lls = zeros(Maxiter,1);
weights = normalize(rand(N,K),2);
model = m_step(model,X,weights);
lls(1) = sum(logprob(model, X));
for it = 2:Maxiter
   resp = e_step(model, X);
   model = m_step(model, X,  resp);
   lls(it) = sum(logprob(model, X));
   if(abs(lls(it)-lls(it-1))/abs(lls(it-1))<1e-5), break; end
end
end

function resp = e_step(model, X)
% compute responsibility
K = length(model.mixWeights);
X = size(X,1);
logpost = zeros(N,K); % WLL(n,k) = log p(X(n,:)|theta,Zn=k) + log p(Zn=k|theta) 
for k=1:K % evaluate for each tree
   logpost(:,k) = logprob(model.trees{k}, X) + log(model.mixWeights(k));
end
resp = exp(normalizeLogspace(logpost)); % normalize along cols of each row
end
