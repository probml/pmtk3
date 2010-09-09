% K-medoids algorithm
% [idx,dpsim]=kmedoids(S,k,nruns,maxits)
%
% Input:
%
%   S         Similarity matrix (see above)
%   K         Number of clusters to find, or a vector of indices
%             of the initial set of exemplars
%   nruns     Number of runs to try, where each run is initialized
%             randomly (default 1)
%   maxits    Maximum number of iterations (default 100)
%
% Ouput:
%
%   idx(i,r)    Index of the data point that data point i is assigned
%               to in the rth run. idx(i,r)=i indicates that point i
%               is an exemplar
%   dpsim(t,r)  Sum of similarities of data points to exemplars, after
%               iteration t in the rth run
%
% Copyright Brendan J. Frey and Delbert Dueck, Aug 2006. This software
% may be freely used and distributed for non-commercial purposes.
%
%PMTKauthor Brendan J. Frey, Delbert Dueck
%PMTKurl http://www.psi.toronto.edu/~frey/apm/kcc.m

% This file is from pmtk3.googlecode.com


% Simplified by Kevin Murphy

function [idx,dpsim]=kmedoids(S,K,nruns,maxits)

if nargin < 3, nruns = 1; end
if nargin < 4, maxits = 100; end

n=size(S,1); dpsim=zeros(maxits,nruns); idx=zeros(n,nruns);
for rep=1:nruns
   tmp=randperm(n)'; mu=tmp(1:K);
   t=0; done = (t==maxits);
   while ~done
      t=t+1; muold=mu; dpsim(t,rep)=0;
      [tmp cl]=max(S(:,mu),[],2); % Find class assignments
      cl(mu)=1:K; % Set assignments of exemplars to themselves
      for j=1:K % For each class, find new exemplar
         I=find(cl==j);
         [Scl ii]=max(sum(S(I,I),1));
         dpsim(t,rep)=dpsim(t,rep)+Scl(1);
         mu(j)=I(ii(1));
      end;
      if isequal(muold,mu) || (t==maxits), done =1; end;
   end;
   idx(:,rep)=mu(cl); dpsim(t+1:end,rep)=dpsim(t,rep);
end;

end
