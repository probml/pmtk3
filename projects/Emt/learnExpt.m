function [params, params0, data] = learnExpt(name, model, numOfMix, Dz, seed, maxIters, ratio)
% learn parameters for a give data'name', using the 'model'
%#function efa_loglik_b
%#function efa_loglik_m
%#function efa_loglik_c
%#function efa_predict_c
%#function efa_predict_b
%#function efa_predict_m
%#function efa_compute_error_c
%#function efa_compute_error_m
%#function efa_compute_error_b

 if nargin < 6, maxIters = 100; end
if nargin < 7, ratio = 0.1; end
ratio

  if isdeployed
    numOfMix = str2double(numOfMix);
    Dz = str2double(Dz);
    seed = str2double(seed);
  end

 
  
  Dz_str = strrep(num2str(Dz),'.','dot'); % replace . by dot
  dirName = getDirNameScratch();
  fileName = sprintf([dirName '%s/%s_%d_%s_%d'],name, model, numOfMix, Dz_str, seed)

  setSeed(seed);
  [data, nClass] = processData(name, struct('ratio',ratio));

  saveOut = 1;
  

  switch model
    case 'ss'
      % TEMPORORY LINE FOR NIPS EXPT, REMOVE THIS
      % get the validated value of Dz
      fileNameTemp = sprintf('/global/scratch/emtiyaz/latentModelsOut/%s/final/%s_%s_%d',name, 'disGaussFA', 'randomMixed', seed);
      load(fileNameTemp);
      Dz = out.DzMin;

      tic
      params.K          = Dz+1;
      params.lambdaBeta = 0;
      params.lambdaZ    = 1;
      params.nClass     = nClass;
      [XtrainObs,RtrainObs,params] = efa_prepare_data(data, params);
      params = efa_learn(XtrainObs,RtrainObs,[],params,struct('method','MM','numIter',5000,'burnin',0.01,'sampleLag',10,'debug',1,'stepSize', .01));
      tt = toc;
      if saveOut 
        save(fileName, 'params','tt');
      end

    case {'mixedMF','mixedMFnoReg'}
      tic
      switch model
      case 'mixedMF'
        valsZ = data.valsZ;
        valsV = data.valsB;
        [params, testErrAll] = learnMixedMF(data, [], struct('valsZ',valsZ, 'valsV', valsV,'Dz',Dz+1,'nClass',nClass,'cv',1, 'MaxIter', maxIters, 'MaxFunEvals', maxIters));
      case 'mixedMFnoReg'
        params = learnMixedMF(data, struct('lambdaZ',0, 'lambdaV', 0), struct('Dz',Dz+1,'nClass',nClass,'cv',0,'display',1, 'MaxIter', maxIters, 'MaxFunEvals', maxIters));
      end
      tt = toc;
      if saveOut 
        save(fileName, 'params','tt');
      end

    case {'gmmDiag','gmmFull','indDisGmmDiag', 'indDisGmmFull'}
      tic
      s0 = 0.1;
      options = struct('maxNumOfItersLearn', maxIters, 'lowerBoundTol', 1e-4, 'regCovMat', 1, 'covMat', 'diag','display',1);

      data.discrete = encodeDataOneOfM(data.discrete, nClass, 'M');
      switch model
        case 'gmmDiag'
          data.discrete = [];
          dataTest.discrete = [];
        case 'gmmFull'
          data.discrete = [];
          dataTest.discrete = [];
          options.covMat = 'full';
        case 'indDisGmmDiag'
          options.covMat = 'diag';
        case 'indDisGmmFull'
          options.covMat = 'full';
      end
      % learn params
      opt=struct('initMethod','random','numOfMix',numOfMix,'scale',3, 'refine', 0, 'nClass', nClass, 's0',s0);
      [params0, data] = initImm(data, [], opt);
      funcName = struct('inferFunc', @inferImm, 'maxParamsFunc', @maxParamsImm);
      [params, trainLogLik] = learnEm(data, funcName, params0, options);
      tt = toc;
      if saveOut 
        save(fileName, 'params','trainLogLik','tt');
      end

    case {'laplace'}
      % hyperparameters
      s0 = .01;
      % encode test data
      data.binary = [];
      data.discrete = encodeDataOneOfM(data.discrete, nClass, 'M+1');

      tic
      opt =struct('Dz', Dz, 's0', s0, 'nClass', nClass, 'initMethod', 'random');
      options = struct('maxNumOfItersLearn', maxIters, 'maxItersInfer', 3, 'lowerBoundTol', 1e-3,'display',1,'checkConvergenceIters',10,'estimateBeta',1,'regCovMat',0, 'estimateCovMat',0,'checkConvergenceMethod','parameter');
      data.categorical= data.discrete;
      data.discrete = [];
      [params0, data] = initMixedDataFA(data, [], opt);
      params0.a = 1;
      params0.b = 1;
      % learn params
      funcName = struct('inferFunc', @inferMixedDataFA_laplace, 'maxParamsFunc', @maxParamsMixedDataFA);
      [params, trainLogLik] = learnEm(data, funcName, params0, options);
      tt = toc;

      if saveOut 
        save(fileName, 'params','trainLogLik','tt');
      end
 
    case 'sparseLGM'
      data.binary = [];
      data.categorical = encodeDataOneOfM(data.discrete, nClass);
      tic
      opt =struct('nClass', nClass, 'initMethod', 'random');
      [params0, data] = initSparseLGM(data, [], opt);
      params0.a = 1;
      params0.b = 1;
      params0.lambdaLaplace = Dz; % regularization parameter for precMat
      options = struct('maxNumOfItersLearn', 1000, 'maxItersInfer', 3, 'lowerBoundTol', 1e-5,...
          'estimateBeta', 1, 'estimateCovMat', 1, 'estimateMean', 1,...
          'display', 1, 'fixDiag', 1, 'l1GeneralFunEvals', 1000, 'l1GeneralMaxIter', 1000,'checkConvergenceIters',10);
      funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsSparseLGM);
      [params, trainLogLik] = learnEm(data, funcName, params0, options);
      params.psi = [];
      params.xi = [];
      tt = toc;
      if saveOut 
        save(fileName, 'params','trainLogLik','tt');
      end

    case {'gaussFA','gaussFullLatent','disGaussFA', 'disGaussFullLatent','disGaussFA_jaakkola'}
      % hyperparameters
      s0 = .01;
      data.binary = [];
      data.discrete = encodeDataOneOfM(data.discrete, nClass, 'M+1');
      inferFuncName = @inferMixedDataFA;
      
      setSeed(0);
      tic
      opt =struct('Dz', Dz, 's0', s0, 'nClass', nClass, 'initMethod', 'random');
      options = struct('maxNumOfItersLearn', maxIters, 'maxItersInfer', 3, 'lowerBoundTol', 1e-3,'display',1,'checkConvergenceIters',10);
      switch model
        case 'gaussFA'
          data.categorical = [];
          [params0, data] = initMixedDataFA(data, [], opt);
          options.estimateBeta = 1;
          options.estimateCovMat = 0;

        case 'disGaussFA'
          data.categorical= data.discrete;
          data.discrete = [];
          [params0, data] = initMixedDataFA(data, [], opt);
          options.estimateBeta = 1;
          options.estimateCovMat = 0;

        case 'disGaussFA_jaakkola'
          data.binary = data.discrete;
          data.discrete = [];
          [params0, data] = initMixedDataFA(data, [], opt);
          options.estimateBeta = 1;
          options.estimateCovMat = 0;
          inferFuncName = @inferMixedDataFA_jaakkola;

        case 'gaussFullLatent'
          data.categorical= [];
          dataTest.categorical = [];
          options.estimateBeta = 0;
          options.estimateCovMat = 1;
          options.regCovMat = 0;
          opt.Dz = size(data.continuous,1);
          [params0, data] = initMixedDataFA(data, [], opt);
          params0.beta = eye(opt.Dz,opt.Dz);
          params0.betaCont = eye(opt.Dz,opt.Dz);

        case 'disGaussFullLatent'
          data.categorical = data.discrete;
          dataTest.categorical = data.discreteTest;
          options.estimateBeta = 0;
          options.estimateCovMat = 1;
          options.regCovMat = 0;
          Dz=size(data.continuous,1)+size(data.categorical,1);
          opt.Dz = Dz;
          [params0] = initMixedDataFA(data, [], opt);
          params0.beta = eye(Dz,Dz);
          params0.betaCont = params0.beta(1:size(data.continuous,1),:);
          params0.betaMult = params0.beta(size(data.continuous,1)+1:end,:);

        otherwise
          error('no such name');
      end
      params0.a = 1;
      params0.b = 1;
      % learn params
      funcName = struct('inferFunc', inferFuncName, 'maxParamsFunc', @maxParamsMixedDataFA);
      [params, trainLogLik] = learnEm(data, funcName, params0, options);
        
      params.psi = [];
      params.xi = [];
      tt = toc;

      if saveOut 
        save(fileName, 'params','trainLogLik','tt');
      end
      
    case 'mixtureFA'
      % encode test data
      data.binary = [];
      data.discrete = encodeDataOneOfM(data.discrete, nClass, 'M+1');
      data.categorical= data.discrete;
      data.discrete = [];

      tic
      opt=struct('Dz', Dz, 'K', numOfMix, 'nClass', nClass);
      options = struct('maxNumOfItersLearn', maxIters, 'maxItersInfer', 3, 'lowerBoundTol', 1e-4,'display',1,'checkConvergenceIters',10, 'estimateBeta',1,'regCovMat',0,'estimateCovMat',0);
      [params0, data] = initMixedDataMixtureFA(data, [], opt);
      params0.a = 1;
      params0.b = 1;
      params0.alpha0 = 0.1;
      % learn params
      funcName = struct('inferFunc', @inferMixedDataMixtureFA, 'maxParamsFunc', @maxParamsMixedDataMixtureFA);
      [params, trainLogLik] = learnEm(data, funcName, params0, options);
      params.psi = [];
      tt = toc;

      if saveOut 
        save(fileName, 'params','trainLogLik','tt');
      end

    otherwise
      error('No such model');
  end
  tt

