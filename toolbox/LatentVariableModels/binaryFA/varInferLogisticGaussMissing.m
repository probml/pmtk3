function [muPost, SigmaPost, logZ, lambda] = varInferLogisticGaussMissing(y, W, b, muPrior, SigmaPriorInv, computeLoglik)
% Just like varInferLogisticGauss except y(t) may be NaN

% This file is from pmtk3.googlecode.com

maxIter = 3;
%[maxIter, computeLoglik] = process_options(varargin, ...
%  'maxIter', 3, 'computeLoglik', (nargout >= 3));
y = colvec(y);
p = numel(y);
visNdx = ~isnan(y);

% initialize variational param 
xi = zeros(p,1);
xi(visNdx) = (2*y(visNdx)-1) .* (W(:,visNdx)'*muPrior + b(visNdx));
ndx = find(xi==0);
xi(ndx) = 0.01*rand(size(ndx));

SigmaInv = SigmaPriorInv; %inv(SigmaPrior);
for iter=1:maxIter
  lambda = zeros(p,1);
  lambda(visNdx) = (0.5-sigmoid(xi(visNdx))) ./ (2*xi(visNdx));

  tmp = W*diag(lambda)*W'; % missing entries have lambda=0
  SigmaPost = inv(SigmaInv - 2*tmp);

  tmp = zeros(p,1);
  tmp(visNdx) = y(visNdx)-0.5 + 2*lambda(visNdx).*b(visNdx);
  tmp2 = sum(W*diag(tmp), 2); % missing entries have tmp=0
  muPost = SigmaPost*(SigmaInv*muPrior + tmp2);
  
 
  tmp = diag(W'*(SigmaPost + muPost*muPost') * W);
  tmp2 = 2*(W*diag(b))'*muPost;
  xi(visNdx) = sqrt(tmp(visNdx) + tmp2(visNdx) + b(visNdx).^2);
  
  
  if ~computeLoglik
    logZ = 0;
  else
    % Normalization constant
    lam = -lambda;
    % -ve sign needed because Tipping
    % uses different sign convention for lambda to Emt/Bishop/Murphy
    A = diag(2*lam);
    invA = diag(1./(2*lam));
    hidNdx = find(~visNdx);
    ndx = sub2ind(size(A), hidNdx, hidNdx);
    invA(ndx) = 0; % set diagonals to 0 for missing entries
    
    bb = -0.5*ones(p,1);
    c = -lam .* xi.^2 - 0.5*xi + log(1+exp(xi));
    ytilde = zeros(p,1);
    ytilde(visNdx) = invA(visNdx,visNdx)*(bb(visNdx) + y(visNdx)); % ytilde is 0 for missing entries
    B = W'; % T*K
    logconst1 = -0.5*sum(log(lam(visNdx)/pi));
    %assert(approxeq(logconst1, 0.5*logdet(2*pi*invA)))
    logconst2 = 0.5*ytilde'*A*ytilde - sum(c(visNdx));
    predMu = B*muPrior + b;
    predPost = invA + B*SigmaPost*B';
    logconst3 = gaussLogprob(predMu(visNdx), predPost(visNdx,visNdx), rowvec(ytilde(visNdx)));
    logZ = logconst1 + logconst2 + logconst3;
    assert(~isnan(logZ))
  end
end

end