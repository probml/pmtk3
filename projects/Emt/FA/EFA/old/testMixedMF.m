  clear all
  setSeed(100)

  % make data
  Dz = 2;
  N = 100;
  mean_ = [5 -5]';
  L = eye(Dz);
  covMat = L*L';
  z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);

  % continuous data
  Dc = 10;
  noiseCovMat = 0.01*eye(Dc);%abs(diag(randn(Dc,1)));
  Bc = rand(Dc,Dz);
  data.continuous = Bc*z + chol(noiseCovMat)*randn(Dc,N);
  data.binary = [];
  data.discrete = [];
  nClass = [];

  % categorical data
  nClass = [2];
  Bm = [];
  for c = 1:length(nClass)
    Bmc = rand(nClass(c)-1,Dz);
    p = [exp(Bmc*z); ones(1,N)];
    pMult = p./repmat(sum(p,1),nClass(c),1);
    data.discrete(c,:) = sum(repmat([1:nClass(c)],N,1).*mnrnd(1,pMult'),2);
    Bm = [Bm; Bmc];
  end

  % create a new dataset with missing continuous vales
  N = 10;
  z = repmat(mean_,1,N) + chol(covMat)*randn(Dz,N);

  % continuous data
  Dc = 10;
  data.continuousTest = Bc*z + chol(noiseCovMat)*randn(Dc,N);
  [D,N] = size(data.continuousTest);
  miss = rand(D,N)<0.1;
  data.continuousTestTruth = data.continuousTest;
  data.continuousTest(miss) = NaN;
  data.discreteTest = [];

  % categorical data
  M = nClass - 1;
  for c = 1:length(nClass)
    idx = sum(M(1:c-1))+1:sum(M(1:c));
    Bmc = Bm(idx,:);
    p = [exp(Bmc*z); ones(1,N)];
    pMult = p./repmat(sum(p,1),nClass(c),1);
    data.discreteTest(c,:) = sum(repmat([1:nClass(c)],N,1).*mnrnd(1,pMult'),2);
  end

  runAlgo = 1;
  if runAlgo 
    % run CV
    valsZ = 0.01;%[0.01 0.1 1 10 100];% for mixedMF
    valsV = 0.01%10.^[-3:.1:1];
    %paramsCv = learnMixedMF(data, [], struct('valsZ',valsZ, 'valsV', valsV,'Dz',Dz,'nClass',nClass,'cv',1));
    % run algo for each value of parameter

    for j = 1:length(valsV)
    j
      params = learnMixedMF(data, struct('lambdaZ',valsZ, 'lambdaV', valsV(j)), struct('Dz',Dz+1,'nClass',nClass,'cv',0));


      % compute test errpr
      infer_data.continuous = data.continuousTest;
      infer_data.discrete   = data.discreteTest;
      [iXb,iXm,iXc] = mixed_mf_prepare_data_emt(infer_data, nClass);
      params.N = size(infer_data.continuous,2);
      [iXbhat,iXmhat,iXchat,Z] = mixed_mf_predict(iXb,iXm,iXc,params);
      testErr(j) = mean(((iXchat(~isnan(iXc)) - iXc(~isnan(iXc))).^2));
      test_data.continuous = data.continuousTestTruth;
      test_data.discrete   = data.discreteTest;
      [tXb,tXm,tXc]        = mixed_mf_prepare_data_emt(test_data, nClass);
      % missing data imputation
      err(j) = mean(((iXchat(isnan(iXc)) - tXc(isnan(iXc))).^2));
      % test log-lik
      params.N = size(data.continuousTest,2);
      W = pack_mixed_mf_params(Z,params.Vb,params.Vm,params.Vc,params.sigma);
      nll(j) = mixed_mf_obj_emt(W,iXb,iXm,iXc,params);
      %save testMixedMf;
    end
  end
  break

  %load testMixedMFauto
  %load testMixedMf
  subplot(121)
  plot(valsV, testErr,'linewidth',2);
  hold on
  idx = find(paramsCv.lambdaV == valsV);
  plot(paramsCv.lambdaV, testErr(idx),'ro','markersize',15,'linewidth',2);
  xlabel('lambda(V)');
  ylabel('testMSE');
  title('test MSE for various values of lambda_V');

  subplot(122)
  plot(valsV, nll, 'linewidth',2)
  title('Negative test log likelihood');
  xlabel('lambda(V)');






