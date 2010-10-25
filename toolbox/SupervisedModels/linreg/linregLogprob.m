function logp = linregLogprob(model, X, y)
%% log p(y(i)|X(i,:), model)

% This file is from pmtk3.googlecode.com


if isfield(model, 'likelihood')
    likelihood = model.likelihood;
else
    likelihood = 'gaussian';
end

mu     = linregPredict(model, X);
sigma2 = model.sigma2;

switch lower(likelihood)
    
    case 'gaussian'
        
        logp = gaussLogprob(mu(:), sigma2, y(:));
        
    case 'student'
        
        logp = studentLogprob(mu, sigma2, model.dof, y); 
        
    otherwise
        error('linregLobprob does not support %s likelihoods');
end



end
