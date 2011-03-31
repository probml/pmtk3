  % Test/Example file for EM for factor analysis
  clear all
  setSeed(2)
  N = 50;
  % generate data
  Dz = 3;
  Dp = 10;

  proto = unidrnd(20, Dp, Dz);
  %z = unidrnd(2, N, 1);
  z = [repmat(1, ceil(N/3),1);  repmat(2, ceil(N/3),1); repmat(3, ceil(N/3),1)];
  y = proto(:,z) + unidrnd(2, Dp, length(z));
  [Dp N] = size(y);

  % get parameters
  params.mean = zeros(Dz,1);
  params.covMat = eye(Dz);
  params.precMat = inv(params.covMat);

  % initialize
  m = rand(Dz,N);
  L = repmat(eye(Dz), [1 1 N]);
  idx = find(repmat(tril(ones(Dz)), [1 1 N]));
  vec0 = [m(:); L(idx)];

  % minimize
  options = [];
  [TolFun, TolX, MaxIter, MaxFunEvals, display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-10,'MaxIter',1000, 'MaxFunEvals',1000, 'display', 1);
  options.Method    = 'lbfgs';
  options.TolFun    = TolFun;
  options.TolX      = TolX;
  options.MaxIter   = MaxIter;
  options.MaxFunEvals = MaxFunEvals;
  options.DerivativeCheck = 'off';
  options.corr = 50;
  options.display = display;

  %vec0 = [vec0];
  %params.beta = rand(Dp,Dz);
  %[f,g]   = funObjInferPoissonFA(vec0,y,params);
  %vec = minFunc(@funObjInferPoissonFA, vec0, options, y,params);

  vec0 = [rand(Dp*Dz,1); vec0];
  [f,g]   = funObjPoissonFA(vec0,y,params);
  vec = minFunc(@funObjPoissonFA, vec0, options, y,params);

  % get m,V, beta
  D = Dp;
  %beta = params.beta;
  beta = reshape(vec(1:Dz*D),D,Dz);
  vec = vec(Dz*D+1:end);
  m = reshape(vec(1:Dz*N), Dz, N);

  nr = 1; nc = 2;
  subplot(nr,nc,1)
  imagesc(y')
  colorbar
  colormap(gray)
  title('data')
  ylabel('Data points')
  xlabel('Dimension')

  subplot(nr,nc,2)
  imagesc(exp(beta*m)');
  colorbar
  colormap(gray)
  title('prediction')
  ylabel('Data points')
  xlabel('Dimension')


