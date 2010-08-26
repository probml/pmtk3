function model = hmmCreate(type, pi, A, emission)
%% Create an hmm model
% See also hmmFit
nstates = numel(pi); 
model = structure(type, pi, A, emission, nstates);
model.modelType = 'hmm';
if strcmpi(type, 'gauss')
    model.d = emission.d;
else
    model.d = 1;
end
end