function [Xrecon, Zhat] = mixModelReconstruct(model, X)
% Compress X then reconstruct it in Xhat
% and return root mean squared error

% This file is from pmtk3.googlecode.com


Zhat = mixModelMapLatent(model, X);
Xrecon = X;
K = model.nmix;
for k=1:K
  ndx = (Zhat==k);
  switch lower(model.type)
    case 'gauss'
      recon = model.mu(:,k);
    case 'discrete'
      % T is of size [nstates, nObsStates, d]
      [nstates, nObsStates, ndims] = size(model.cpd.T); %#ok
      recon = zeros(1,ndims);
      for j=1:ndims
        recon(j) = maxidx(model.cpd.T(k,:,j), [], 2);
      end
  end
  Xrecon(ndx,:) = repmat(rowvec(recon), sum(ndx), 1);
end

end
