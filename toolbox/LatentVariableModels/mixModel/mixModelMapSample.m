function [X, y] = mixModelSample(model, nsamples)
%% Sample from a mixture model 

% This file is from pmtk3.googlecode.com


y = sampleDiscrete(model.mixWeight, nsamples, 1);
switch lower(model.type)
    
    case 'gauss'
        
        mu    = model.cpd.mu;
        Sigma = model.cpd.Sigma; 
        d     = size(Sigma, 1); 
        X     = zeros(nsamples, d);
        for j = 1:nsamples
             X(j, :) = gaussSample(mu(:, y(j)), Sigma(:, :, y(j)), 1);
        end
            
    case 'discrete'
        
        T = model.cpd.T;
        d = size(T, 3);
        X = zeros(nsamples, d);
        for i=1:nsamples
            for j=1:d
                X(i, j) = sampleDiscrete(T(:, y(i), j), 1);
            end
        end
        
    case 'student'
        
        error('not yet implemented'); 
        
    otherwise
        error('%s is not a recognized mixture model type', model.type); 
end


end