function [localCPDs, localCPDpointers, localMu, localSigma] = ...
  condGaussCpdMultiFit(X, obs, Nstates)
% Fit a set of conditional Gaussian distributions
% Xj -> obsj for j=1:Nnodes
% X is Ncases*Nnodes, X(i,j) = {1..K}
% obs(i,j,:) are the observations for node j in case i
% So obs is Ncases * Nnodes * Ndims

[Ncases Nnodes Ndims] = size(obs); %#ok
localCPDs = cell(1, Nnodes);
localCPDpointers = 1:Nnodes; % each node has its own CPD
%Nstates = nunique(X(:));

localMu = zeros(Ndims,  Nstates, Nnodes);
localSigma = zeros(Ndims, Ndims, Nstates, Nnodes);

for t=1:Nnodes
  Y = squeeze(obs(:,t,:)); % Y(case,dim)
  Z = canonizeLabels(X(:,t)); %
  if nunique(Z) < Nstates
    % not enough data, dude
    sprintf('node %d only has %d states\n', t, nunique(Z));
  end
  % Estimate mean and variance of observations for this node
  % for each possible state
  %mu    = partitionedMean(Y, Z, Nstates)';
  %Sigma = partitionedCov(Y, Z,  Nstates);
  Sigma = zeros(Ndims, Ndims, Nstates);
  mu = zeros(Ndims, Nstates);
  for c=1:Nstates
    ndx = (Z==c);
    % We compute MAP estimate of Sigma instead of MLE using weak prior
    % to avoid numerical problems
    %gausscpd = gaussFit(Y(ndx,:), 'map');
    %mu(:,c) = gausscpd.mu;
    %Sigma(:,:,c) = gausscpd.Sigma;
    mu(:,c) = mean(Y(ndx,:))';
    Sigma(:,:,c) = shrinkcov(Y(ndx,:));
  end
  localCPDs{t} = condGaussCpdCreate(mu,  Sigma);
 
  localMu(:,:,t) = mu;
  localSigma(:,:,:,t) = Sigma;
end

end