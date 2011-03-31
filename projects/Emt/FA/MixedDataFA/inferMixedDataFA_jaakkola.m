function [ss, logLik, postDist] = inferMixedDataFA_jaakkola(data, params, options)
% inference for continuous + binary using Jaakkola's bound

  [computeSs, computeLogLik, estimateBeta, maxItersInfer] = myProcessOptions(options, 'computeSs', 1, 'computeLogLik', 1, 'estimateBeta', 1, 'maxItersInfer', 5);

  [Dc,Nc] = size(data.continuous);
  [Db,Nb] = size(data.binary);
  N = max([Nb Nc]);
  Dz = size(params.mean,1);

  multiplyMatrixWithVec = @(V,i) V*i;

  % precompute some quantities
  xi = [];
  miss_cont = [];
  y = [];
  noisePrecMat = [];
  inform = zeros(Dz,N);
  inform = bsxfun(@plus, inform, params.precMat*params.mean); % prior
  BpsiB = params.precMat;
  if Db>0
    miss_bin = isnan(data.binary);
    yb = data.binary;
    yb(miss_bin) = 0;
    xi = params.xi;
    miss_bin_struct = mat2cell(miss_bin, Db, ones(1,N));
    inform= inform + params.betaBin'*(yb -0.5); % binary
    logBin = 0;
  end
  if Dc>0
    miss_cont = isnan(data.continuous);
    miss_cont_struct = mat2cell(miss_cont, Dc, ones(1,N));
    yc = data.continuous;
    yc(miss_cont) = 0;
    y = data.continuous;% pseudo measurement;
    noisePrecMat = zeros(Dc,N);
    noisePrecMat = bsxfun(@plus, noisePrecMat, diag(params.noisePrecMat));
    inform=inform + params.betaCont'*params.noisePrecMat*yc;
    if ~sum(sum(miss_cont))
      BpsiB = BpsiB + params.betaCont'*params.noisePrecMat*params.betaCont;
    end
  end
  %inform_struct = mat2cell(inform,Dz,ones(1,N)); 
  yb_struct = mat2cell(data.binary, Db, ones(1,N));
  D = Dc + Db;

  if Db >0 
    for i = 1:maxItersInfer
      % jaakkola's bound
      A = (1./(1+exp(-xi))-0.5)./xi;
      Astruct = mat2cell(A,Db,ones(1,N));
      if ~sum(sum(miss_cont))
        % if no missing continuous
        informPrior = params.precMat*params.mean;
        [meanPost_struct, covMatPost_struct, precMatPost_struct] = cellfun(@(measurement, a, m1)computePostMixed(measurement, a, m1, BpsiB, params.betaBin, informPrior), yb_struct, Astruct, miss_bin_struct,'uniformoutput',0);
      else
        [meanPost_struct, covMatPost_struct, precMatPost_struct] = cellfun(@(i,a,m1,m2)computePostMixedMissingCont(i, a, m1, m2, params), inform_struct, Astruct, miss_bin_struct, miss_cont_struct, 'uniformoutput',0);
      end
      covMatPost = reshape(cell2mat(covMatPost_struct), [Dz Dz N]);
      precMatPost = reshape(cell2mat(precMatPost_struct), [Dz Dz N]);
      meanPost =cell2mat(meanPost_struct);

      % optimize xi
      BVB = cell2mat(cellfun(@(V)computeBVB(V, params.betaBin),covMatPost_struct, 'uniformOutput',0));
      xi = sqrt((params.betaBin*meanPost).^2 + BVB);
    end
    % pseudo measurement
    y_b = (data.binary - 0.5)./A;
    y = [y; y_b]; % pseudo measurement 
    noisePrecMat = [noisePrecMat; A];
    % log likelihood contribution
    y_b(miss_bin) = 0;
    c = -0.5*(A.*(xi.^2) + xi) + log(1+exp(xi));
    logBin = 0.5*sum(sum(~miss_bin))*log(2*pi)...
                - 0.5*sum(sum(~miss_bin.*log(A)))...
                + 0.5*sum(sum(y_b.*(A.*y_b))) - sum(~miss_bin(:).*c(:)); 

  elseif Dc >0 
    [ss, logLik, postDist] = inferFA(data, params, options);
    return;
  else
    error('Emtpty data?');
  end

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
    postDist.xi = xi;
  end

  missY = isnan(y);
  y0 = y;
  y0(missY) = 0;
  % sufficient statistics
  if computeSs
    ss.xi = xi;
    ss.sumMean = sum(meanPost,2); 
    %ss.noisePrecMat = noisePrecMat;
    ss.sumCovMat = sum(covMatPost,3) + meanPost*meanPost';
    diff = bsxfun(@minus, meanPost, params.mean);
    ss.sumCovMat1 = sum(covMatPost,3) + diff*diff';
    if estimateBeta
      ss.sumLhs = y0*meanPost';
      if sum(sum(missY))
        for d = 1:D
          % then compute sum over all observed
          obs_d = find(~missY(d,:));
          B = meanPost(:,obs_d)*meanPost(:,obs_d)' + sum(covMatPost(:,:,obs_d),3);
          ss.beta(d,:) = ss.sumLhs(d,:)*inv(B);
        end
      end
    end
    % Phi
    if Dc>0
      P = cell2mat(cellfun(@(V)computeBVB(V, params.betaCont), covMatPost_struct, 'uniformoutput',0));
      ss.sumPhi = sum(((~missY(1:Dc,:).*(y0(1:Dc,:) - params.betaCont*meanPost)).^2 + ~missY(1:Dc,:).*P(1:Dc,:)), 2);
    end
  else
    ss = 0;
  end

  % log Lik
  logLik = 0;
  if computeLogLik
    % compute inv(Psi)*diag(BVB')
    noisePrecMat_struct = mat2cell(~missY.*noisePrecMat, D, ones(1,N));
    PsiBVB = -0.5*sum(cellfun(@(Psi,V)computePsiBVB(Psi, V, params.beta), noisePrecMat_struct, covMatPost_struct));
    % measurement link likelihood
    err = ~missY.*(y0-params.beta*meanPost);
    logLink = -0.5*sum(~missY(:))*log(2*pi) + 0.5*sum(sum(~missY.*log(noisePrecMat))) - 0.5*sum(sum(err.*(noisePrecMat.*err))) + PsiBVB;
    % latent variable log prob
    t =  -0.5*sum(cellfun(@(V)computeTrace(params.precMat, V), covMatPost_struct));
    logLatent = sum(logMvnPdfWithMissingData(params.mean, [1:N], meanPost, params.precMat)) + t;

    % entropy
    e =  0.5*sum((cellfun(@(V)logdet(V), covMatPost_struct)));
    entrpy = 0.5*N*log(2*pi)*Dz + e;

    % prior on parameters
    logPrior = 0;
    if Dc >0
      logPrior = - (params.a + 1)*sum(log(diag(params.noiseCovMat)))...
        - params.b*sum(diag(params.noisePrecMat));
    end
    switch params.priorCovMat
    case 'invWishart'
      logPrior = logPrior + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);
    case 'laplace'
      %logPrior = logPrior - 0.5*N*params.lambdaLaplace*sum(sum(abs(setdiag(params.precMat,0))));
      lambda  = N*params.lambdaLaplace/2;
      logPrior = logPrior - params.lambdaLaplace*sum(sum(abs(setdiag(params.precMat,0))));% + log(params.lambdaLaplace/2);
    otherwise
      error('No such prior for covMat');
    end
    %logPrior = logPrior + 0.5*(params.nu0+Dz+1)*logdet(params.precMat) - 0.5*trace(params.S0*params.precMat);

    logLik = logLink + logLatent + entrpy + logBin + logPrior;
    logLik = logLik/N;
  end

function out = computeBVB(V, beta)
  out = diag(beta*V*beta');

function out = computePsiBVB(Psi, V, beta)
  out = sum(Psi.*diag(beta*V*beta'));

%function P = computeDiagBVB(V, B) 
%  P = diag(B*V*B');

function t = computeTrace3(A,B,C) 
  t = trace(A*B*C);

function t = computeTrace(A,B) 
  t = trace(A*B);

function [meanPost, covMatPost, precMatPost] = computePostMixedMissingCont(inform, A, miss_bin, miss_cont, params)
  
  obs_bin = find(~miss_bin);
  obs_cont = find(~miss_cont);
  precMatPost = params.betaCont(obs_cont,:)'*params.noisePrecMat(obs_cont,obs_cont)*params.betaCont(obs_cont,:) + params.betaBin(obs_bin,:)'*(bsxfun(@times, A(obs_bin), params.betaBin(obs_bin,:))) + params.precMat;
  covMatPost = inv(precMatPost);
  meanPost = covMatPost*inform;  

function [meanPost, covMatPost, precMatPost] = computePostMixed(yb, A, miss_bin, BsiB, betaBin, priorInform)
  
  obs = find(~miss_bin);
  precMatPost = BsiB + betaBin(obs,:)'*(bsxfun(@times, A(obs), betaBin(obs,:)));
  covMatPost = inv(precMatPost);
  meanPost = covMatPost*(betaBin(obs,:)'*(yb(obs) -0.5) + priorInform);  


