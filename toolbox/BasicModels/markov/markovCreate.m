function model = markovCreate(pi, A, nstates)
%% Create a simple Markov model
% PMTKdefn Markov(x | \pi, A)
% See also markovFit
%%

% This file is from pmtk3.googlecode.com

model = structure(pi, A, nstates);
model.modelType = 'markov';
end
