function [pred, logLik] = imputeMissingMixedDataMixtureFA(func, data, params, options)
% Imputes missing data in MixedDataMixtureFA

  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  [Db,Nb] = size(data.binary);
  N = max([Nc, Nm, Nb]);
  [Dz, K] = size(params.mean);

  % set options for inference
  options.maxItersInfer = 20;
  options.computeSs = 0;
  options.computeLogLik = 0;
  % initialize variational parameters
  if Dm >0
    params.psi = rand(sum(params.nClass-1),N,K);
  else
    params.psi = [];
  end
  if Db >0
    params.xi = rand(Db,N,K);
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
      yhat = zeros(Dc, length(miss_n));
      for k = 1:K
        y = mat2cell(data.continuous(:,miss_n), Dc, ones(1,length(miss_n)));
        mean_ = mat2cell(postDist.mean(:,miss_n,k), Dz, ones(1,length(miss_n)));
        yhat_k = cellfun(@(x,m)computeBm(x,m,params.beta(:,:,k)), y, mean_, 'uniformoutput',0);
        yhat_k = cell2mat(yhat_k);
        yhat = yhat + bsxfun(@times, postDist.mixProb(k,miss_n), yhat_k);
      end
      pred.continuous(:,miss_n) = yhat;
    end
  end
  % impute binary variables 
  if Db>0
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
  end
  % impute discrete variables 
  if Dm>0
    M = params.nClass -1;
    ym = data.categorical;
    pred.categorical = data.categorical;
    for d = 1:length(M)
      idx = sum(M(1:d-1))+1:sum(M(1:d));
      miss_d = find(sum(isnan(ym(idx,:)),1));
      probFin = zeros(length(idx),length(miss_d));
      for k = 1:K
        beta_d = params.betaMult(idx,:,k);
        Amhat = exp([beta_d; zeros(1,Dz)]*postDist.mean(:,:,k));
        prob_d = bsxfun(@times,Amhat,1./sum(Amhat,1));
        probFin = probFin + bsxfun(@times, postDist.mixProb(k,miss_d), prob_d(1:end-1,miss_d));
      end
      pred.categorical(idx,miss_d) = probFin;

      %{
      if ~isempty(miss_d)
        if M(d) == 0
          % impute binary bariables
          for n = 1:length(miss_d)
            sigma2(n) = params.betaMult(idx,:)*postDist.covMat(:,:,miss_d(n))*params.betaMult(idx,:)';
          end
          mean_ = params.betaMult(idx,:)*postDist.mean(:,miss_d);
          kappa = 1./sqrt(1 + pi.*sigma2./8);
          data.categorical(idx,miss_d) = sigmoid(mean_.*kappa);
          data.categoricalProbs(idx,miss_d) = sigmoid(mean_.*kappa);
          clear sigma2;
        else
          % multinomial variables
          for n = 1:length(miss_d)
            % laplace approximation for integral
            logI = zeros(M(d),1);
            for c = 1:M(d)+1
              gradFunc = @(z)softMaxWrtFeatures1(z, beta_d, c);
              funObj = @(z)penalizedGaussian(z, gradFunc, postDist.mean(:,miss_d(n)), postDist.precMat(:,:,miss_d(n)));
              zOpt = minFunc(funObj, zeros(Dz,1), struct('display',0,'derivativecheck','off')); 
              [nll,g,H] = penalizedGaussian(zOpt, gradFunc, postDist.mean(:,miss_d(n)), postDist.precMat(:,:,miss_d(n)));
              logI(c) = exp(-nll - 0.5*logdet(H));
              %logI(c) = exp(-nll + logdet(2*pi*inv(H)));
            end
            prob = exp(logI - logsumexp(logI(:),1));
            % class with max prob
            [v, class] = max(prob);
            data.categorical(idx,miss_d(n)) = encodeDataOneOfM(class, M(d)+1, 'M+1');
            data.categoricalProbs(idx,miss_d(n)) = prob(1:end-1);
            data.discrete(idx,miss_d(n)) = prob(1:end-1);
          end
        end
      end
      %}
    end
  end

function y = computeBm(y, m, B)
  idx = find(isnan(y));
  y(idx) = B(idx,:)*m;


  
