function [ss] = updateSsGmm(ss, data, varDist, options)
% update Ss for GMM
% written by Emtiyaz, CS, UBC
% Modified on April 05, 2010

  idxMiss = find(isnan(data));
  data(idxMiss) = 0;
  K = length(varDist.mixProb);
  D = length(data);
  [resp, sumY, sumYY] = myProcessOptions(ss,'resp',0,'sumY',0,'sumYY',0);
  resp = resp + varDist.mixProb(:);
  sumY = sumY + repmat(varDist.mixProb(:)',D,1).*repmat(data(:),1,K);
  sumYY = sumYY + reshape(repmat(varDist.mixProb(:)',D^2,1),D,D,K).*repmat(data(:)*data(:)',[1 1 K]);
  ss = struct('sumY',sumY,'sumYY',sumYY, 'resp',resp);

