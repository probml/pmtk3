function [params, data] = initMixtureFA(data, params, options)

  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  N = max([Nc Nm]);
  params.Dc = Dc;
  params.Dm = Dm;

  [Dz, K, s0, scale, initMethod, nClass] = myProcessOptions(options, 'Dz',2,'K',2,'s0', 1, 'scale', 3, 'initMethod', 'random','nClass', []);

  params.mixProb = rand(K,1);
  % set regularization parameters for covMat
  params.S0 = s0*eye(Dz);
  params.nu0 = Dz + 2;
  params.covMat = repmat(eye(Dz,Dz), [1 1 K]);
  params.precMat = repmat(eye(Dz,Dz), [1 1 K]);
  params.mean = scale*randn(Dz,K);
  if ~isfield(params, 'lambda')
    params.lambda = 0;%regularization for B
  end
  if ~isfield(params, 'a')
    params.a = -1;
    params.b = 0;
  end
  if ~isfield(params, 'alpha0')
    params.alpha0 = 0;
  end

  params.beta = [];
  switch initMethod 
    case 'random'
      if Dc > 0
        params.noiseCovMat = eye(Dc,Dc);
        params.noisePrecMat = inv(params.noiseCovMat);
        params.betaCont = rand(Dc,Dz,K);
        params.beta = [params.beta; params.betaCont];
      end
    otherwise
      error('no such method')
  end

  if Dm > 0
    if ~isfield(params, 'nClass')
      if ~isempty(nClass) 
        params.nClass = nClass;
      else
        error('nClass not defined, pass it through options');
      end
    end
    for d = 1:length(params.nClass)
      M = params.nClass(d)-1;
      A{d} = 0.5*(eye(M) - ones(M,M)/(M+1));
      invA{d} = inv(A{d});
    end

    params.A = A;
    params.invA = invA;
    params.betaMult = rand(sum(params.nClass-1),Dz,K);
    params.beta = [params.beta; params.betaMult];
    for k = 1:K
      params.psi(:,:,k) = params.betaMult(:,:,k)*repmat(params.mean(:,k), 1,N);
    end
  end

  if ~isfield(data, 'YY')
    y = data.continuous;
    y(isnan(y)) = 0;
    data.YY = sum(y.*y,2);
  end

