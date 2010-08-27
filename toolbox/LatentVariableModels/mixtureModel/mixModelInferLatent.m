function [pZ, ll] = mixModelInferLatent(model, X)
%% Compute pZ(i, k) = p( Z = k | X(i, :), model) 
% ll(i) = log p(X(i, :) | model)  
%%
nmix   = model.nmix; 
[n, d] = size(X); 
logMix = log(rowvec(model.mixWeight)); 
logPz  = zeros(n, nmix); 
switch model.type  
    case 'gauss'
        
        mu    = model.cpd.mu;
        Sigma = model.cpd.Sigma; 
        for k = 1:nmix
            logPz(:, k) = logMix(k) + gaussLogprob(mu(:, k), Sigma(:, :, k), X);
        end
        
    case 'discrete'
        
        logT = log(model.cpd.T + eps); 
        Lijk = zeros(n, d, nmix);
        for j = 1:d
            Lijk(:, j, :) = logT(X(:, j), :, j);
        end
        logPz = bsxfun(@plus, logMix, squeeze(sum(Lijk, 2)));

    case 'student'
        
        mu    = model.cpd.mu;
        Sigma = model.cpd.Sigma;
        dof   = model.cpd.dof; 
        for k = 1:nmix
             logPz(:, k) = logMix(k) + studentLogprob(mu(:, k), Sigma(:, :, k), dof(k), X);
        end
end
[logPz, ll] = normalizeLogspace(logPz);
pZ          = exp(logPz);
end