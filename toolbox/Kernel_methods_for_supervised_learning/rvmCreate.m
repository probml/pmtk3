function model = rvmCreate(likelihood, w, gamma, hyperParams, preproc)
%% Construct an rvm model
switch lower(likelihood)
    case 'gaussian'
        outputType = 'regression';
    case 'bernoulli'
        outputType = 'binary'; 
end
model = structure(likelihood, w, gamma, hyperParams, preproc, outputType); 

end