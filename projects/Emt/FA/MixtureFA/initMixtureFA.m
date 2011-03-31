function [params, data] = initMixtureFA(data, params, options)

  [Dc,N] = size(data.continuous);

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
  if ~isfield(data, 'YY')
    y = data.continuous;
    y(isnan(y)) = 0;
    data.YY = sum(y.*y,2);
  end

