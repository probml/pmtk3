function model = hmmCreate(type, pi, A, emission, nstates)
%% Create an hmm model
%PMTKlatentModel hmm
% See also hmmFit
model = structure(type, pi, A, emission, nstates);
model.modelType = 'hmm';
if strcmpi(type, 'gauss')
    model.d = emission.d;
else
    model.d = 1;
end
end