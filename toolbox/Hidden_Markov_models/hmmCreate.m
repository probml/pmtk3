function model = hmmCreate(type, pi, A, emission, nstates)
%% Create an hmm model
%PMTKlatentModel hmm
% See also hmmFit
model = structure(type, pi, A, emission, nstates); 
model.modelType = 'hmm';

end