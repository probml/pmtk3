function S = betaSample(model, n)
% Return n samples from a beta distribution with parameters model.a,
% model.b. 
S = colvec(randraw('Beta', [model.a, model.b], n));
end