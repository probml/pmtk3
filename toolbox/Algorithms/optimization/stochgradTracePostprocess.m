
% This file is from pmtk3.googlecode.com

function [fHist, favgHist] = stochgradTracePostprocess(trace, objFun, X, y, varargin)


T = size(trace.params,1);
fHist = zeros(1,T);
favgHist = zeros(1,T);
for t=1:T
  fHist(t) =  objFun(trace.params(t,:)', X, y, varargin{:});
  if isfield(trace, 'paramsAvg')
    favgHist(t) =  objFun(trace.paramsAvg(t,:)', X, y, varargin{:});
  end
end

end
