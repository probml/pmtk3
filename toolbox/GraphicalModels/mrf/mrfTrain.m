function [mrf, loglikHist] = mrfTrain(mrf, data, varargin)
%% Train an mrf with partially observed data via EM
% This does not currently update the undirected parameters, only the local
% CPDs, but will be generalized at a later point. 

% This file is from pmtk3.googlecode.com




[mrf, loglikHist] = mrfTrainEm(mrf, data, varargin{:}); 

end
