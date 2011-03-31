function [ss, logLik, postDist] = inferMixedDataFA_laplace2(data, params, options)
% inference for  discrete data based on laplace approximation
% doesn't work right now.

  [Dc,Nc] = size(data.continuous);
  [Dm,Nm] = size(data.categorical);
  N = max([Nm Nc]);
  Dz = size(params.mean,1);
  multiplyMatrixWithVec = @(V,i) V*i;

  M = params.nClass - 1;

  % compute postDist
  ym = mat2cell(data.categorical, sum(M), ones(1,N));
  [meanPost_struct, covMatPost_struct, precMatPost_struct] = cellfun(@(y)inferLaplace(y, params), ym,'uniformoutput',0);
  covMatPost = reshape(cell2mat(covMatPost_struct), [Dz Dz N]);
  precMatPost = reshape(cell2mat(precMatPost_struct), [Dz Dz N]);
  meanPost =cell2mat(meanPost_struct);

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


function [meanPost, covMatPost, precMatPost] = inferLaplace(ym, params)

  M = params.nClass - 1;
  Dz = size(params.mean,1);
  % optimize for z
  gradFunc = @(z)softMaxWrtFeatures1(z, params.betaMult, M, ym);
  funObj = @(z)penalizedGaussian(z, gradFunc, params.mean, params.precMat);
  zOpt = minFunc(funObj, zeros(Dz,1), struct('display',0,'derivativecheck','off')); 

  % compute the posterior distribution
  [nll,g,H] = penalizedGaussian(zOpt, gradFunc, params.mean, params.precMat);
  precMatPost = H;
  covMatPost = inv(precMatPost);
  meanPost = zOpt;

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
      out(idx) = inv(A + 1e-10*eye(size(A,1)))*ym(idx);
    end
  end

function [nll,g,H] = softMaxWrtFeatures1(z, B, M, y)

  nll = 0; g= 0; H = 0;
  L = size(B,2);
  for d = 1:length(M)
    idx = sum(M(1:d-1))+1:sum(M(1:d));
    B_d = [B(idx,:); zeros(1,L)];
    y_d = find(y(idx));
    if isempty(y_d)
      y_d = M(d)+1;
    end
    switch nargout
    case 1
      [nll_d] = softMaxWrtFeatures(z,B_d,y_d);
      nll = nll + nll_d;
    case 2
      [nll_d,g_d] = softMaxWrtFeatures(z,B_d,y_d);
      nll = nll + nll_d;
      g = g + g_d;
    case 3
      [nll_d,g_d,H_d] = softMaxWrtFeatures(z,B_d,y_d);
      nll = nll + nll_d;
      g = g + g_d;
      H = H + H_d;
    otherwise
      error('too many output');
    end
  end


