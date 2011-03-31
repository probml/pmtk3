function [out, logLik] = sparseLGM(task, data, params, options)
% runs different tasks for sparseLGM model
% TODO need to add option argument

  if isempty(options)
    options.nClass = max(data.discrete,[],2);
  end
  data.binary = [];
  nClass = options.nClass;
  data.categorical = encodeDataOneOfM(data.discrete, nClass);

  switch task
  case 'learn'
    % initialize
    opt =struct('nClass', nClass, 'initMethod', 'random');
    [params0, data] = initSparseLGM(data, [], opt);
    params0.a = 1;
    params0.b = 1;
    params0.lambdaLaplace = params; 
    options = struct('maxNumOfItersLearn', 5000,...
                      'maxItersInfer', 20,...
                      'lowerBoundTol', 1e-8, ...
                      'estimateBeta', 1,...
                      'estimateCovMat', 1,...
                      'estimateMean', 1, ...
                      'display', 1,...
                      'fixDiag', 1,...
                      'l1GeneralFunEvals', 1000,...
                      'l1GeneralMaxIter', 1000);
    funcName = struct('inferFunc', @inferMixedDataFA,...
                      'maxParamsFunc', @maxParamsSparseLGM);
    % run EM
    tic
    [params, trainLogLik] = learnEm(data, funcName, params0, options);
    logLik = trainLogLik(end);
    tt = toc;
    params.psi = [];
    out = params;

  case 'infer'
    options = struct( 'maxItersInfer', 20, 'lowerBoundTol', 1e-5);
    params.psi =  randn(size(data.categorical));
    [ss, logLik, postDist] = inferMixedDataFA(data, params, options);
    out = postDist;

  case 'impute'
    options = struct( 'maxItersInfer', 20, 'lowerBoundTol', 1e-5);
    pred = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, data, params, []);
    % recode categorical to discrete
    pred.discrete = [];
    if ~isempty(nClass)
      Md = nClass - 1;
      for d = 1:length(nClass)
        idx = sum(Md(1:d-1))+1:sum(Md(1:d));
        prob_d = pred.categorical(idx,:);
        prob_d = [prob_d; 1-sum(prob_d,1)];
        pred.discrete = [pred.discrete; prob_d];
      end
    end
    logLik = NaN;
    out = pred;

  otherwise
    error('No such task');
  end
