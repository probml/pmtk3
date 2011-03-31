function [params, data] = initSparseLGM(data, params, options)

  if ~isfield(data, 'continuous'); data.continuous = []; end;
  if ~isfield(data, 'binary'); data.binary = []; end;
  if ~isfield(data, 'categorical'); data.categorical = []; end;

  [Dc,Nc] = size(data.continuous);
  [Db,Nb] = size(data.binary);
  [Dm,Nm] = size(data.categorical);
  N = max([Nb Nc Nm]);
  params.Dc = Dc;
  params.Db = Db;
  params.Dm = Dm;

  [scale, nClass, initMethod] = myProcessOptions(options, 'scale', 3, 'nClass', [], 'initMethod', 'random');

  % numver of latent variables
  Dz = Dc + Db + length(nClass);
  % laplace prior for covMat
  params.priorCovMat = 'laplace';
  params.lambdaLaplace = 0.01;
  % initial values
  params.covMat = eye(Dz,Dz);
  params.precMat = inv(params.covMat);
  % mean
  params.mean = zeros(Dz,1);
  % regularization for loading factors
  params.lambda = 0;
  % regularization for noise covariance 
  params.a = -1;
  params.b = 0;

  % intialize loading factors
  % continuous
  params.beta = [];
  if Dc > 0
    switch initMethod 
      case 'random'
        params.noiseCovMat = eye(Dc,Dc);
        params.noisePrecMat = inv(params.noiseCovMat);
        params.betaCont = eye(Dc,Dz);
        params.beta = [params.beta; params.betaCont];
      case 'PCA'
      %{
        mean_ = mean(data.continuous,2);
        Y = bsxfun(@minus, data.continuous,  mean_);
        covMat = Y*Y';
        [U,S,V] = svd(covMat);
        params.noiseCovMat = sum(sum((covMat - U(:,1:Dz)*S(1:Dz,1:Dz)*V(:,1:Dz)').^2))*eye(Dc,Dc);
        params.noisePrecMat = inv(params.noiseCovMat);
        params.betaCont = U(:,1:Dz)*sqrt(S(1:Dz,1:Dz));
        params.beta = [params.beta; params.betaCont];
        %}
      otherwise
        error('no such method')
    end
  end
  % binary
  if Db > 0
    params.betaBin = eye(Db,Dz);
    params.beta = [params.beta; params.betaBin];
    params.xi = rand(Db,N);
  end
  % categorical
  if Dm > 0
    if ~isfield(params, 'nClass')
      if ~isempty(nClass) 
        params.nClass = nClass;
      else
        error('nClass not defined, pass it through options');
      end
    end
    betaMult  = [];
    % curvature for Bohning bound
    for d = 1:length(params.nClass)
      M = params.nClass(d)-1;
      A{d} = (eye(M) - ones(M,M)/(M+1))/2;
      invA{d} = inv(A{d});
      betaMult_d = zeros(M,Dz);
      betaMult_d(:,Dc+Db+d) = ones(M,1);
      betaMult = [betaMult; betaMult_d];
    end
    params.A = A;
    params.invA = invA;
    params.betaMult = betaMult;
    params.beta = [params.beta; params.betaMult];
    % variational parameters
    params.psi = params.betaMult*repmat(params.mean, 1,N);
  end

  % precompute y.^2 and add it to the data
  if Dc >0
    if ~isfield(data, 'YY')
      y = data.continuous;
      y(isnan(y)) = 0;
      data.YY = sum(y.*y,2);
    end
  end

