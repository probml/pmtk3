% Compare various joint density models on categorical (mostly binary) datsets
% We visualize the learned structuers and evaluated loglik on test set

%% Data
% labels is N*D, where labels(n,d) in {1..Nstates(d)}

folder = '/Users/kpmurphy/Dropbox/Students/Emt/datasets';
load(fullfile(folder, 'a3newsgroupsTrainTestEmail.mat'))
[N, D] = size(train.labels)
Nstates = 2*ones(1,D);
nClass = 2*ones(1,D);
fold = 1;

%% Models/ methods

methods = [];
m = 0;

%{
  
m = m + 1;
methods(m).modelname = 'indep';
methods(m).fitFn = @(labels) discreteFit(labels);
methods(m).logprobFn = @(model, labels) discreteLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) discretePredictMissing(model, labels);




m = m + 1;
methods(m).modelname = 'mix120';
methods(m).fitFn = @(labels) mixModelFit(labels, 120, 'discrete', 'maxIter', 20, 'verbose', false);
methods(m).logprobFn = @(model, labels) mixModelLogprob(model, labels);
methods(m).predictMissingFn = @(model, labels) mixModelPredictMissing(model, labels);

%}


%%%%%%%%%%%%%% Categorical FA



%[mu, Sigma, loglikCases, loglikAvg] = catFAinferLatent(model,discreteData, ctsData)
%[predD, predC] = catFApredictMissing(model, testData)
m = m + 1;
methods(m).modelname = 'catFA-40';
methods(m).fitFn = @(labels) catFAfit(labels, [],  40, 'maxIter', 1, ...
  'nClass', nClass, 'verbose', true);
methods(m).logprobFn = @(model, labels) argout(3, @catFAinferLatent, model, labels, []);
methods(m).predictMissingFn = @(model, labels) argout(3, @catFApredictMissing, model, labels, []);



Nmethods = numel(methods);



  [Ntrain, Nnodes] = size(train.labels);
  [Ntest, Nnodes2] = size(test.labels);
 
 
  models = cell(1, Nmethods);
  methodNames = cell(1, Nmethods);
  for m=1:Nmethods
    methodNames{m} = sprintf('%s', methods(m).modelname); 
    fprintf('fitting %s\n', methodNames{m});
    models{m} = methods(m).fitFn(train.labels);
  end
 

  ll = zeros(1, Nmethods);
  imputationErr = zeros(1,Nmethods);
  for m=1:Nmethods
    fprintf('evaluating %s\n', methodNames{m});
    %ll(m) = sum(methods(m).logprobFn(models{m}, test.labels))/Ntest;
    
    if isfield(methods(m), 'predictMissingFn')
      pred = methods(m).predictMissingFn(models{m}, test.labelsMasked);
      % for binary data - MSE is fine
      %probOn = pred(:,:,2);  
      %imputationErr(m) = sum(sum((probOn-test.tags).^2))/Ntest; 
      
      %{
      % for K-ary data - MSE not so meaningful
      % so we use cross entropy
      [~,truth3d] = dummyEncoding(test.labels, Nstates);
      %imputationErr(m) = sum(sum(sum((truth3d-pred).^2)))/Ntest;
      %logprob = sum(sum(log(sum(truth3d .* pred, 3))))/Ntest;
      
      % Just assess performance on the missing entries
      % This does not affect the relative performance of methods
      logprob = log(sum(truth3d .* pred, 3)); % N*D
      logprobAvg = sum(sum(logprob(missingMask)))/sum(missingMask(:));
      %}
        
      % Emt's evaluation code
      
      nClass = Nstates;
       yd = test.labelsMasked';
       ydT = test.labels';
        ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
        yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
        N = size(yd_oneOfM,2);
      miss = isnan(yd_oneOfM);
      yhatD = pred.discrete;
      entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(N*length(nClass))
      logprobAvg = entrpyD;
  
      
      %{
      % From imputeExpt_2
      switch imputeName
        case {'randomDiscrete','randomMixed','artificial'}
          if ~isempty(testData.discrete)
            ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
            yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
            N = size(yd_oneOfM,2);
            miss = isnan(yd_oneOfM);
            yhatD = pred.discrete;
            mseD = mean((ydT_oneOfM(miss) - yhatD(miss)).^2);
            entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))/(N*length(nClass));
          end
       %}
      
      imputationErr(m) = -logprobAvg;
    end
  end
  loglik_models(fold, :) = ll;
  imputation_err_models(fold, :) = imputationErr;
  




%% Plot performance

[styles, colors, symbols, plotstr] =  plotColors();

%{
% NLL - exclude catFA, which cannot compute valid loglik
figure;
ndx = 1:2
if Nfolds==1
  plot(-loglik_models(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(-loglik_models(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('negloglik on %s', dataName))
fname = fullfile(figFolder, sprintf('negloglik-%s.png', dataName));
print(gcf, '-dpng', fname);
%}

% imputation error
figure;
ndx = 2:Nmethods % exclude indep
if Nfolds==1
  plot(imputation_err_models(ndx), 'x', 'markersize', 12, 'linewidth', 2)
  axis_pct
else
  boxplot(imputation_err_models(:, ndx))
end
set(gca, 'xtick', 1:numel(ndx))
set(gca, 'xticklabel', methodNames(ndx))
%xticklabelRot(methodNames(ndx), -45);
title(sprintf('imputation error on %s with %5.3f percent missing', ...
  dataName, pcMissing))
fname = fullfile(figFolder, sprintf('imputation-%s.png', dataName));
print(gcf, '-dpng', fname);


%% Visualize models themselves

break

m = strfindCell('tree', methodNames);
if ~isempty(m)
  tree = models{m};
  % The tree is undirected, but for some reason, gviz makes directed graphs
  % more readable than undirected graphs
  fname = fullfile(figFolder, sprintf('tree-%s', dataName))
  graphviz(tree.edge_weights, 'labels', nodeNames, 'directed', 1, 'filename', fname);
end

m = strfindCell('dgm', methodNames);
if ~isempty(m)
  dgm = models{m};
  % The node names get permuted so we must use dgm.nodeNames
  fname = fullfile(figFolder, sprintf('dgm-%s', dataName))
  graphviz(dgm.G, 'labels', dgm.nodeNames, 'directed', 1, 'filename', fname);
end

m = strfindCell('mrf-L1', methodNames);
if ~isempty(m)
  mrf = models{m};
  fname = fullfile(figFolder, sprintf('mrf-L1-%s', dataName))
  graphviz(mrf.G, 'labels', nodeNames, 'directed', 0, 'filename', fname);
end


m = strfindCell('mix10', methodNames);
if ~isempty(m)
  mix = models{m};
  K = mix.nmix;
  [nr,nc] = nsubplots(K);
  %figure;
  for k=1:K
    T = squeeze(mix.cpd.T(k,2,:));
    ndx = topAboveThresh(T, 5, 0.1);
    memberNames = sprintf('%s,', nodeNames{ndx});
    disp(memberNames)
    %subplot(nr, nc, k)
    %bar(T);
    %title(sprintf('%5.3f', mix.mixWeight(k)))
  end
end


%{
% Fit a depnet to the labels
%model = depnetFit(labels, 'nodeNames', nodeNames, 'method', 'ARD');
model = depnetFit(labels, 'nodeNames', nodeNames, 'method', 'MI');
fname = fullfile(figFolder, sprintf('depnet-MI-%s', dataName))
graphviz(model.G, 'labels', nodeNames, 'directed', 1, 'filename', fname);
%}


