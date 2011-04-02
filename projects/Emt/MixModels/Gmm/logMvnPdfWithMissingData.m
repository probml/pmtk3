function logNorm = logMvnPdfWithMissingData(data, obs, mean_, precMat, logDetPrecMat, covMat)
% Computes log of Multivariate Normal Pdf when data contains missing values.
% logNorm = logMvnPdfWithMissingData(data, obs, mean_, precMat) computes the
% logPdf for data (#dim x #measurements). 'obs' contains the indexes of
% measurements which are fully observed. mean_ is (#dim x1) and precMat is
% (#dim x #dim).
% To speed up computation, logDet of precMat can be specified. If missing data
% is present, covMat can be passed in to avoid its computation inside.
% 
% Written By Emtiyaz, CS, UBC
% Modified on April 08, 2010

  if isempty(data)
    logNorm = 0;
    return;
  end
  [D,N] = size(data);
  log2pi = log(2*pi);
  % check if data contains missing values or not
  if length(find(obs)) < N
    containsMissingData = 1;
  else
    containsMissingData = 0;
  end
  % compute logdetPrecMat is not specified
  if nargin < 5
      logDetPrecMat = logdet(precMat);
  end
  % compute logNorm
  logNorm = zeros(1,N);
  err = bsxfun(@minus, data, mean_);
  if ~containsMissingData
    logNorm = 0.5*(logDetPrecMat - D*log2pi) ...
        - 0.5*sum(err.*(precMat*err),1);
  else
    % for partially observed use cellfun
    if nargin < 6
      covMat = inv(precMat);
    end
    miss = ones(1,N);
    miss(obs) = 0;
    miss = find(miss);
    logNorm(miss) = cellfun(@(y)myLogNormPdf(y, covMat), mat2cell(err(:,miss), D, ones(1,length(miss))));
    % for fully observed use the code as before 
    logNorm(obs) = 0.5*(logDetPrecMat - D*log2pi) ...
        - 0.5*sum(err(:,obs).*(precMat*err(:,obs)),1);
  end

function val = myLogNormPdf(y, covMat) 
% compute lognormpdf, call this inside cellfun
  i = find(~isnan(y));
  val = -0.5*length(i)*log(2*pi) - 0.5*(logdet(covMat(i,i))) - 0.5*y(i)'*inv(covMat(i,i))*y(i); 

