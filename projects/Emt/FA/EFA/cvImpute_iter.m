function [bestmodel, models,tt] = cvImpute_iter(models, data, vals1, vals2, otherParams, options)
% cv function for imputeExpt.m

  [nFolds, splitRatio, display, discrete, missProb, fileName] = myProcessOptions(options, 'nFolds',5,'splitRatio', 0.7,'display',1, 'discrete',0, 'missProb', 0.1, 'fileName','temp');

  if(isempty(models));fromscratch=1;else;fromscratch=0;end;

  tt=0;
  Dz = otherParams.Dz;
  nClass = otherParams.nClass;
  % cv
  for i = 1:length(vals1)
    for j = 1:length(vals2)
      for c = 1:nFolds
        setSeed(c);
        dataCv = splitDataCv(data, splitRatio, missProb);

          [TolFun, TolX, MaxIter, MaxFunEvals, display] = myProcessOptions(options, 'TolFun',1e-6, 'TolX', 1e-6,'MaxIter',2, 'MaxFunEvals',2, 'display', 1);
          options.Method    = 'lbfgs';
          options.TolFun    = TolFun;
          options.TolX      = TolX;
          options.MaxIter   = MaxIter;
          options.MaxFunEvals = MaxFunEvals;
          options.DerivativeCheck = 'off';
          options.corr = 50;
          options.display = display;

          lambdaZ = vals1(i); 
          lambdaV = vals2(j);
          % run MixedMF
          [Xb,Xm,Xc,params] = mixed_mf_prepare_data_emt(dataCv, nClass);
          params.K = Dz;
          params.lambdaV = lambdaV;
          params.lambdaZ = lambdaZ;

          if(fromscratch)
            Winit = mixed_mf_init_params(Xb,Xm,Xc,params);
          else
            Winit = pack_mixed_mf_params(models{i,j,c}.Z,models{i,j,c}.Vb,models{i,j,c}.Vm,models{i,j,c}.Vc,models{i,j,c}.sigma);
          end
 
          tic
          models{i,j,c} = mixed_mf_learn_emt(Xb, Xm, Xc, Winit, params, options);

         % test error 
          infer_data.continuous = dataCv.continuousTest;
          infer_data.discrete   = dataCv.discreteTest;
          [iXb,iXm,iXc]         = mixed_mf_prepare_data_emt(infer_data, nClass);

          test_data.continuous  = dataCv.continuousTestTruth;
          test_data.discrete    = dataCv.discreteTestTruth;
          [tXb,tXm,tXc]         = mixed_mf_prepare_data_emt(test_data, nClass);
          
          Nc = size(infer_data.continuous,2);
          Nd = size(infer_data.discrete,2);
          %modelMF.N = max(Nc,Nd);
          [iXbhat,iXmhat,iXchat] = mixed_mf_predict(iXb,iXm,iXc,models{i,j,c});

          %Get missing values in inference set with known ground truth
          missc = ~isnan(tXc) & isnan(iXc);
          missb = ~isnan(tXb) & isnan(iXb);
          missm = ~isnan(tXm) & isnan(iXm);

          %Compute errors
          err(c) = 0;
          if any(missc)
            err(c) = err(c) + mean(((iXchat(missc) - tXc(missc)).^2));
          end
	  if any(missb)
	    err(c) = err(c) + mean(((iXbhat(missb) - tXb(missb)).^2));
	  end
	  if any(missm)
	    err(c) = err(c) + mean(((iXmhat(missm) - tXm(missm)).^2));
	  end

          fprintf('Split %d testErr %f time Taken %f\n',c, err(c), toc);
          testErrAll(i,j,c) = err(c);

          tt = tt + toc;

          if(isnan(err(c)));keyboard;end;

      end
      testErr(i,j) = mean(err);
      fprintf('%1.0e, %1.2e : %f\n\n',vals1(i),vals2(j),testErr(i,j));
    end
  end

  [i,j,foo] = find(testErr==min(testErr(:)));
  bestmodel = models{i,j,1};

function dataCv = splitDataCv(data, ratio, missProb)
% split data into training and testing

  [Dc,Nc] = size(data.continuous);
  [Dd,Nd] = size(data.discrete);
  N = max(Nd,Nc);
  nTrain = ceil(ratio*N);
  idx = randperm(N);

  %Add synthetic missing data to predicto for 
  if Dc>0
    dataCv.continuousTest = data.continuous(:,idx(nTrain+1:end));
    dataCv.continuousTestTruth = data.continuous(:,idx(nTrain+1:end));
    dataCv.continuous = data.continuous(:,idx(1:nTrain));

    [D,N] = size(dataCv.continuousTest);
    miss = rand(D,N)<missProb;
    dataCv.continuousTest(miss) = NaN;

  else
    dataCv.continuousTest = [];
    dataCv.continuousTestTruth = [];
    dataCv.continuous= [];
  end
  if ~isempty(data.discrete)
    dataCv.discreteTest = data.discrete(:,idx(nTrain+1:end));
    dataCv.discreteTestTruth = data.discrete(:,idx(nTrain+1:end));
    dataCv.discrete = data.discrete(:,idx(1:nTrain));

    obs   = find(~isnan(dataCv.discreteTest));
    nobs  = length(obs);
    perm  = randperm(nobs);
    ind   = 1:ceil(nobs*missProb); 
    miss  = obs(perm(ind));

    [D,N] = size(dataCv.discreteTest);
    %miss = rand(D,N)<missProb;
    dataCv.discreteTest(miss) = NaN;

  else
    dataCv.discreteTest = [];
    dataCv.discreteTestTruth = [];
    dataCv.discrete = [];
  end

