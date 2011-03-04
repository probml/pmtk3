function [mi, nmi, pij, pi] = mutualInfoAllPairsDiscrete(X, values, weights)
% Compute mutual information between all pairs of discrete rv's
%
% INPUT
% X(n,j) is value of case n=1:N, node j=1:d
% values is set of valid values for each node (e.g., [0 1])
% weights is an optional N*1 vector of weights per data case 
%
% OUTPUT
% mi(i,j) = mutual information between X(i) and X(j), mi(i,i)=0
% nmi = normalize MI, 0 <=nmi <= 1
% pij(i,k,v1,v2) = joint
% pi(i,v) = marginal
%
% COMPLEXITY
% O(N d^2) time to compute p(i,j), N=#cases, d=#nodes.
% O(d^2 K^2) time to compute MI, K=#states
%


% This file is from pmtk3.googlecode.com


%PMTKauthor Sam Roweis
%PMTKmodified Kevin Murphy

% This implementation is efficient since it only ever uses
% for loops over the states K, which are often binary.
% There is no loop over n or d.

% If the data is binary and sparse, there is a trick
% to save space
% let N(t) = sum_n I(X(n,t)=1), N(s,t)=sum_n I(X(n,s)=1,X(n,t)=1)
% Then we can compute the pairwise statistics thus:
% N(s=1,t=1) = N(s,t)
% N(s=1,t=0) = N(s) - N(s,t)
% N(s=0,t=1) = N(t) - N(s,t)
% N(s=0,t=0) = N - [-N(s,t) + N(s) + N(t)]
% where the last line follows from the Venn diagram
%  [a, b'] (a,b)  [a', b]




data = full(double(X')); % now columns contain cases
clear X
if nargin < 2, values = unique(data(:)); end
[numvar N] = size(data); 
numval = length(values);
if nargin < 3, weights = ones(1,N); end
weights = repmat(weights(:)', numvar,1); 

% collect counts and calculate joint probabilities
% pij(x1,x2,v1,v2) = prob(x1=values(v1),x2=values(v2))
pij = zeros(numvar,numvar,numval,numval);
for v1=1:numval,
  for v2=1:numval,
    %pij(:,:,v1,v2) = full((documents==values(v1))*(documents==values(v2))');
    A = double(data==values(v1)) .*weights;
    B = double(data==values(v2));
    % A(x1,d) = 1 iff D(x1,d)=v1,  B(x2,d) = 1 iff D(x2,d) = v2
    % pij(x1,x2,v1,v2) = sum_d A(x1,d)  B(x2,d) = A*B'
    pij(:,:,v1,v2) = A*B';
  end;
end;
pij = pij/N;

% calculate marginal probabilities
% pi(x1,v) = pij(x1,x1, v,v)
pi2 = reshape(pij,numvar^2,numval^2);
pi = pi2(find(eye(numvar)),find(eye(numval))); %#ok

% Calculate entropies and mutual information
% We need to avoid log of 0.
% if pi(x,v)=0 for all v, then entropy(pi(x,:)) = 0
% since -sum_v pi(x,v) log pi(x,v) = 0
% Hence it is safe to replace 0 with eps inside the log
minprob = 1/N; % eps;
hi  = -sum(pi.*log(max(pi,minprob)),2);
hiRep  = hi(:,ones(1,numvar)); % like using repmat
hij = -sum(sum(pij.*log(max(pij,minprob)),3),4);
mi = -hij+hiRep+hiRep'; 
mi = setdiag(mi,0);
if nargout >= 2
  m1 = repmat(hi(:), 1, numvar);
  m2 = repmat(hi(:)', numvar, 1);
  m3 = min(m1, m2);
  nmi = mi ./ m3;
end

end
