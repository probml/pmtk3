function [mseC, mseD, entrpyD, data] = imputeExpt_2(imputeName, name, model, numOfMix, Dz, seed, ratio)
% read the learn params file, create dataset with missing values, impute those
% and save the file
% This file is modified for the final version of paper

if nargin < 7, ratio = 0.7; end
ratio

  if isdeployed
    numOfMix = str2double(numOfMix);
    Dz = str2num(Dz);
    seed = str2double(seed);
  end

  [saveOut, missProbC, missProbD] = myProcessOptions([], 'saveOut',1, 'missProbC', 0.3, 'missProbD', 0.3);
  dirName = getDirNameScratch();
  fileName = sprintf('%s/%s/%s_%d_%d_%d', dirName, name, model, numOfMix,Dz,seed);
  

  setSeed(seed);
  %[data, nClass] = processData(name, []);
 [data, nClass] = processData(name, struct('ratio',ratio));
 
  % create missing data in the test set
  ycT = data.continuousTestTruth;
  ydT = data.discreteTestTruth;
  testData.continuous = ycT;
  testData.discrete = ydT;
  switch imputeName
  case 'randomContinuous'
    % random missing in continuous data
    if ~isempty(ycT)
      miss = (rand(size(ycT))<missProbC);
      testData.continuous(miss) = NaN;
    end
  case 'randomDiscrete'
    % random missing in discrete data
    if ~isempty(ydT)
      miss = rand(size(ydT))<missProbD;
      testData.discrete(miss) = NaN;
    end
  case 'randomMixed'
    % random missing in both
    if ~isempty(ydT)
      miss = rand(size(ydT))<missProbC;
      testData.discrete(miss) = NaN;
    end
    if ~isempty(ycT)
      miss = rand(size(ycT))<missProbD;
      testData.continuous(miss) = NaN;
    end
  case 'artificial'
    % artificial missingness
    testData.continuous = data.continuousTest;
    testData.discrete = data.discreteTest;
  otherwise
    error('no such name');
  end

  yd = testData.discrete;
  yc = testData.continuous;

  % imputation
  load(fileName);
  switch model
  case {'mixedMF','mixedMFnoReg'}
      infer_data.continuous = testData.continuous;
      infer_data.discrete   = testData.discrete;
      params.N = max(size(infer_data.continuous,2), size(infer_data.discrete,2));
      [iXb,iXm,iXc] = mixed_mf_prepare_data_emt(infer_data, nClass);
      [iXbhat,iXmhat,iXchat] = mixed_mf_predict(iXb,iXm,iXc,params);
      % collect binary and multinomial data,
      % rearrange into one discrete data
      prob = [];
      if ~isempty(nClass)
        idx = find(nClass ~= 2);
        Md = nClass(idx);
        cb = 1; cm = 1;
        for d = 1:length(nClass)
          if nClass(d) == 2
            prob_d = [iXbhat(:,cb)'; 1-iXbhat(:,cb)'];
            cb = cb+1;
          else
            idx = sum(Md(1:cm-1))+1:sum(Md(1:cm));
            prob_d = iXmhat(:,idx)';
            cm = cm+1;
          end
          prob = [prob; prob_d];
        end
      end

      % prediction
      pred.discrete = prob;
      pred.continuous = iXchat';

  case {'gaussFA','gaussFullLatent'}
    testData.discrete = [];
    testData.categorical = [];
    testData.binary = [];
    [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferFA_miss, testData, params, []);

  case {,'disGaussFA', 'disGaussFullLatent'}
    testData.categorical = encodeDataOneOfM(testData.discrete, nClass, 'M+1');
    testData.binary = [];
    [pred, logLik] = imputeMissingMixedDataFA_ver1(@inferMixedDataFA_miss, testData, params, []);
    % pred for discrete (add the sum of probs as last row to predictions)
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

  case {'mixtureFA'}
    testData.categorical = encodeDataOneOfM(testData.discrete, nClass, 'M+1');
    testData.binary = [];
    [pred, logLik] = imputeMissingMixedDataMixtureFA(@inferMixedDataMixtureFA_miss, testData, params, []);
    % pred for discrete (add the sum of probs as last row to predictions)
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

  case {'gmmDiag','gmmFull','indDisGmmDiag', 'indDisGmmFull'}
    switch model
    case {'gmmDiag','gmmFull'}
      testData.discrete = [];
    case {'indDisGmmDiag', 'indDisGmmFull'}
      testData.discrete = encodeDataOneOfM(testData.discrete, nClass, 'M');
      miss = isnan(testData.discrete);
      testData.discrete(miss) = 0;
    end
    [pred, logLik] = imputeMissingImm(testData, params, struct('regCovMat',0));

  otherwise
    error('no such name');
  end

  % if pred for some category is zero, entropy will be inf. We add eps to avoid
  % this
  M = params.nClass;
  for d = 1:length(M)
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    p1 = pred.discrete(idx,:);
    if ~isempty(find(sum(p1,2) == 0))
      p1 = p1 + eps;
      p1 = bsxfun(@times, p1, 1./sum(p1));
    end
    pred.discrete(idx,:) = p1;
  end

  % compute MSE
  mseC = NaN;
  mseD = NaN;
  switch imputeName
  case {'randomContinuous','artificial','randomMixed'}
    if ~isempty(testData.continuous)
      miss = isnan(yc);
      yhatC = pred.continuous;
      mseC = mean((ycT(miss) - yhatC(miss)).^2); 
    end
  end
  switch imputeName
  case {'randomDiscrete','randomMixed','artificial'}
    if ~isempty(testData.discrete)
      ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
      yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
      N = size(yd_oneOfM,2);
      miss = isnan(yd_oneOfM);
      yhatD = pred.discrete;
      mseD = mean((ydT_oneOfM(miss) - yhatD(miss)).^2); 
      entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(N*length(nClass))
    end
  end

  % save results
  if saveOut
    switch imputeName
    case 'randomMixed'
      cMseRandomMixed = mseC
      dMseRandomMixed = mseD
      entrpyRandomMixed = entrpyD
      save(fileName,'cMseRandomMixed','dMseRandomMixed','entrpyRandomMixed','-append');
    case 'randomDiscrete'
      cMseRandomDiscrete = mseC
      dMseRandomDiscrete = mseD
      entrpyRandomDiscrete = entrpyD
      save(fileName,'cMseRandomDiscrete','dMseRandomDiscrete','entrpyRandomDiscrete','-append');

    case 'randomContinuous'
      cMseRandomContinuous = mseC
      dMseRandomContinuous = mseD
      entrpyRandomContinuous = entrpyD
      save(fileName,'cMseRandomContinuous','dMseRandomContinuous','entrpyRandomContinuous','-append');

    case 'artificial'
      cMseArtificial= mseC
      dMseArtificial= mseD
      entrpyArtificial = entrpyD
      save(fileName,'cMseArtificial','dMseArtificial','entrpyArtificial','-append');
    otherwise
      error('no such imputeName');
    end
  end


