function [ss, logLik, postDist] = inferMixedDataFA_laplace(data, params, options)
% inference for continuous + binary using (variational) laplace approximation  

  maxItersInfer = options.maxItersInfer;
  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  N = max([Nm Nc]);
  Dz = size(params.mean,1);
  multiplyMatrixWithVec = @(V,i) V*i;

  % precompute some quantities
  psi = [];
  miss_cont = [];
  y = [];
  inform = zeros(Dz,N);
  inform = bsxfun(@plus, inform, params.precMat*params.mean); % prior
  BpsiB = 0;
  if Dm>0
    M = params.nClass -1;
    Dm = length(M);
    miss_mult= isnan(data.categorical);
    ym = data.categorical;
    ym(miss_mult) = 0;
    psi = params.psi;
    miss_mult_struct = mat2cell(miss_mult, sum(M), ones(1,N));
  end
  if Dc>0
    miss_cont = isnan(data.continuous);
    miss_cont_struct = mat2cell(miss_cont, Dc, ones(1,N));
    yc = data.continuous;
    yc(miss_cont) = 0;
    y = data.continuous;% pseudo measurement;
    inform=inform + params.betaCont'*params.noisePrecMat*yc;
    if ~sum(sum(miss_cont))
      BpsiB = BpsiB + params.betaCont'*params.noisePrecMat*params.betaCont;
    end
  end
  D = Dc + sum(M);

  if Dm >0 
    for i = 1:maxItersInfer
      % laplace approximation
      b = [];
      for d = 1:Dm
        idx = sum(M(1:d-1))+1:sum(M(1:d));
        psi_d = psi(idx,:);
        P = exp(myLogSoftMax([psi_d; zeros(1,N)]));
        prob(idx,:) = P(1:end-1,:);
        Ppsi = prob(idx,:).*psi_d;
        % b_d = Ppsi - bsxfun(@times, prob(idx,:), sum(Ppsi,1));
        b_d = Ppsi - bsxfun(@times, prob(idx,:), sum(Ppsi,1)) - prob(idx,:);
        b = [b; b_d]; 
      end
      informMult = inform + params.betaMult'*(~miss_mult.*(ym +b));
      inform_struct = mat2cell(informMult,Dz,ones(1,N)); 
      prob_struct = mat2cell(prob, sum(M), ones(1,N));
      if ~sum(sum(miss_cont))
        % if no missing continuous
        [meanPost_struct, covMatPost_struct, precMatPost_struct] = cellfun(@(i, p, m1)computePostMixed(i, p, m1, BpsiB, params), inform_struct, prob_struct, miss_mult_struct,'uniformoutput',0);
      else
        [meanPost_struct, covMatPost_struct, precMatPost_struct] = cellfun(@(i,p,m1,m2)computePostMixedMissingCont(i, p, m1, m2, params), inform_struct, prob_struct, miss_mult_struct, miss_cont_struct, 'uniformoutput',0);
      end
      covMatPost = reshape(cell2mat(covMatPost_struct), [Dz Dz N]);
      precMatPost = reshape(cell2mat(precMatPost_struct), [Dz Dz N]);
      meanPost =cell2mat(meanPost_struct);

      % optimize psi
      psi = params.betaMult*meanPost;
    end
  else
    error('Emtpty data?');
  end
  % laplace approximation
  b = [];
  for d = 1:Dm
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    psi_d = psi(idx,:);
    P = exp(myLogSoftMax([psi_d; zeros(1,N)]));
    prob(idx,:) = P(1:end-1,:);
    Ppsi = prob(idx,:).*psi_d;
    b_d = Ppsi - bsxfun(@times, prob(idx,:), sum(Ppsi,1)) - prob(idx,:);
    b = [b; b_d]; 
  end
  % get pseudo measurements
  i_m_struct = mat2cell(data.categorical + b, sum(M), ones(1,N));
  y = [y; cell2mat(cellfun(@(im,p)computePseudoMeasurement(im, p, params), i_m_struct, prob_struct, 'uniformoutput', 0))];

  % postDist
  if nargout > 2
    postDist.mean = meanPost;
    postDist.precMat = precMatPost;
    postDist.covMat = covMatPost;
    postDist.psi = psi;
  end

  missY = isnan(y);
  y0 = y;
  y0(missY) = 0;
  % sufficient statistics
  if options.computeSs
    ss.psi = psi;
    ss.sumMean = sum(meanPost,2); 
    %ss.noisePrecMat = noisePrecMat;
    if options.estimateCovMat | options.estimateBeta
      ss.sumCovMat = sum(covMatPost,3) + meanPost*meanPost';
    end
    if options.estimateBeta
      ss.sumLhs = y0*meanPost';
      if sum(sum(missY))
        for d = 1:D
          % then compute sum over all observed
          obs_d = find(~missY(d,:));
          A = meanPost(:,obs_d)*meanPost(:,obs_d)' + sum(covMatPost(:,:,obs_d),3);
          ss.beta(d,:) = ss.sumLhs(d,:)*inv(A);
        end
      end
    else
      % Phi
      if Dc>0
        P = cell2mat(cellfun(@(V)computeBVB(V, params.betaCont), covMatPost_struct, 'uniformoutput',0));
        ss.sumPhi = sum(((~missY(1:Dc,:).*(y0(1:Dc,:) - params.betaCont*meanPost)).^2 + ~missY(1:Dc,:).*P(1:Dc,:)), 2);
      end
    end
  else
    ss = 0;
  end

  logLik = rand;

function [meanPost, covMatPost, precMatPost] = computePostMixedMissingCont(inform, p, miss_mult, miss_cont, params)
  
  obs_cont = find(~miss_cont);
  BpsiB = params.betaCont(obs_cont,:)'*params.noisePrecMat(obs_cont,obs_cont)*params.betaCont(obs_cont,:)  + params.precMat;
  [meanPost, covMatPost, precMatPost] = computePostMixed(inform, p, miss_mult, BpsiB, params);


function [meanPost, covMatPost, precMatPost] = computePostMixed(inform, p, miss_mult, BpsiB, params)
  
  Dm =length(params.nClass); 
  M = params.nClass-1;
  for d = 1:Dm
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    if ~sum(miss_mult(idx))
      p_d = p(idx);
      A = diag(p_d) - p_d*p_d';
      BpsiB = BpsiB + params.betaMult(idx,:)'*A*params.betaMult(idx,:);
    end
  end
  precMatPost = BpsiB + params.precMat;
  covMatPost = inv(precMatPost);
  meanPost = covMatPost*inform;  

function out = computePseudoMeasurement(ym,p, params)

  Dm =length(params.nClass); 
  M = params.nClass-1;
  miss_mult = isnan(ym);
  out = ym;
  for d = 1:Dm
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    if ~sum(miss_mult(idx))
      p_d = p(idx);
      A = diag(p_d) - p_d*p_d';
      out(idx) = inv(A + 0*eye(size(A,1)))*ym(idx);
    end
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


