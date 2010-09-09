function mrf2 = dgmToMrf2(dgm, varargin)
%% Convert a dgm to a pairwise Markov random field
% for use by Mark Schmidt's UGM library
% See mrf2Create for additional optional args
%
%%

% This file is from pmtk3.googlecode.com

mrf2 = factorGraphToMrf2(dgmToFactorGraph(dgm), varargin{:}); 
end
