function [samples] = gibbsSampler(data, params, options)
% Gibbs sampler for multivariate normal model as described in Peter Hoff's book.
% data is a matrix of dim by #datapoints. Params is structure of
% hyperparameters.
% 
% Written by Emtiyaz, CS, UBC 
% Modified on Jan 29, 2010

  % options
  [nSamples] = myProcessOptions(options,'nSamples',1000);
  % hyperparameters
  mean0 = params.mean0;
  precMat0 = inv(params.covMat0);
  nu0 = params.nu0;
  S0 = params.S0;

  [d,n] = size(data);
  Sigma = inv(S0);
  mu = mean0;
  for i = 1:nSamples
    % sample Sigma given mu
    nu = nu0 + n;
    diff = data - repmat(mu,1,n);
    S = S0 + diff*diff';
    Sigma = iwishrnd(S,nu);

    % sample mu given Sigma
    precMat = inv(Sigma);
    covMat = inv(precMat0 + n*precMat);
    mean_ = covMat*(precMat0*mean0 + n*precMat*mean(data,2)); 
    mu = mean_ + chol(covMat)*randn(d,1);

    % collect samples
    samples.mu(:,i) = mu;
    samples.Sigma(:,:,i) = Sigma;
  end


