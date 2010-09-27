function model = markovCreate(pi, A, nstates)
%% Create a simple Markov model
% PMTKdefn Markov(x | \pi, A)
% See also markovFit
%%

% This file is from pmtk3.googlecode.com

if nargin < 3, nstates = numel(pi); end
model = structure(pi, A, nstates);
model.modelType = 'markov';
end
