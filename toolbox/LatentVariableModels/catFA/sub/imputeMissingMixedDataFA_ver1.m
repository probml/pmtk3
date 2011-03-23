function [pred, logLik] = imputeMissingMixedDataFA_ver1(func, data, params, options)
% cleaner version of imputeMissingMixedDataFA.m
% Imputes missing data in MixedDataFA

  [computeLogLik]=myProcessOptions(options,'computeLogLik',0);
  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  [Db,Nb] = size(data.binary);
  N = max([Nc, Nm, Nb]);
  Dz = length(params.mean);

  % set options for inference
  options.maxItersInfer = 20;
  options.computeSs = 0;
  options.computeLogLik = computeLogLik;

  % initialize variational parameters
  if Dm >0
    params.psi = rand(sum(params.nClass-1),N);
  else
    params.psi = [];
  end
  if Db >0
    params.xi = rand(Db,N);
  else
    params.xi = [];
  end

  % inference
  [ss, logLik, postDist] = func(data, params, options);

  % impute continuous values
  if Dc >0
    pred.continuous = data.continuous;
    missing = isnan(data.continuous);
    miss_n = find(sum(missing,1));
    if ~isempty(miss_n)
      y = mat2cell(data.continuous(:,miss_n), Dc, ones(1,length(miss_n)));
      mean_ = mat2cell(postDist.mean(:,miss_n), Dz, ones(1,length(miss_n)));
      yhat = cellfun(@(x,m)computeBm(x,m,params.beta), y, mean_, 'uniformoutput',0);
      yhat = cell2mat(yhat);
      pred.continuous(:,miss_n) = yhat;
    end
  else
    pred.continuous = [];
  end
  % impute binary variables 
  if Db>0
    ym = data.binary;
    pred.binary= data.binary;
    for d = 1:Db
      miss_d = find(sum(isnan(ym(d,:)),1));
      beta_d = params.betaBin(d,:);
      Amhat = exp([beta_d; zeros(1,Dz)]*postDist.mean);
      prob_d = bsxfun(@times,Amhat,1./sum(Amhat,1));
      pred.binary(d,miss_d) = prob_d(1:end-1,miss_d);
    end

    %{
    pred.binary = data.binary;
    yb = data.binary;
    for d = 1:Db
      miss_d = find(isnan(yb(d,:)));
      if ~isempty(miss_d)
        for n = 1:length(miss_d)
          sigma2(n) = params.betaBin(d,:)*postDist.covMat(:,:,miss_d(n))*params.betaBin(d,:)';
        end
        mean_ = params.betaBin(d,:)*postDist.mean(:,miss_d);
        kappa = 1./sqrt(1 + pi.*sigma2./8);
        pred.binary(d,miss_d) = sigmoid(mean_.*kappa);
        clear sigma2;
      end
    end
    %}
  else
    pred.binary = [];
  end
  % impute discrete variables 
  if Dm>0
    M = params.nClass -1;
    ym = data.categorical;
    pred.categorical = data.categorical;
    for d = 1:length(M)
      idx = sum(M(1:d-1))+1:sum(M(1:d));
      miss_d = find(sum(isnan(ym(idx,:)),1));
      beta_d = params.betaMult(idx,:);
      Amhat = exp([beta_d; zeros(1,Dz)]*postDist.mean);
      prob_d = bsxfun(@times,Amhat,1./sum(Amhat,1));
      pred.categorical(idx,miss_d) = prob_d(1:end-1,miss_d);
    end
  else
    pred.categorical = [];
  end

function y = computeBm(y, m, B)
  idx = find(isnan(y));
  y(idx) = B(idx,:)*m;


  
