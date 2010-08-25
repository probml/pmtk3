function model = markovCreate(pi, A, nstates)
%% Create a simple Markov model
% PMTKdefn Markov(x | \pi, A)
% See also markovFit
%%
model = structure(pi, A, nstates);
model.modelType = 'markov';
end
