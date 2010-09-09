function [model, loglikTrace] = gaussMissingFitICM(data, varargin)
% Perform imputation using the ICM algorithm -- plugging in posterior mode
% data is an n*d design matrix with NaN values
% Optional arguments and their defaults:
% maxIter [100] - when to stop the ICM algorithm
% tol  [1e-4] - convergence tolerance for the loglikelihood
% verbose [false]

% This file is from pmtk3.googlecode.com


% Written by Cody Severinski and Kevin Murphy

[maxIter, opttol, verbose] = process_options(varargin, ...
    'maxIter', 100, 'tol', 1e-4, 'verbose', false);

allMissing = find(all(isnan(data),2));
data = data(setdiffPMTK(1:size(data,1), allMissing),:);
[n,d] = size(data);
dataMissing = isnan(data);
missingRows = any(dataMissing,2);
missingRows = find(missingRows == 1);
X = data;

% Initialize params
mu = nanmeanPMTK(data); %mu = mu(:);
Sigma = diag(nanvarPMTK(data));

iter = 1;
converged = false;
currentLL = -inf;


while(~converged)
    % replace missing values with posterior mode
    for i=missingRows(:)'
        u = dataMissing(i,:); % unobserved entries
        o = ~u; % observed entries
        %Sooinv = inv(Sigma(o,o));
        Soo = Sigma(o, o); 
        X(i,u) = mu(u) + ((Sigma(u,o)/Soo)*((X(i,o)-mu(o)))')'; % plugin posterior mode.
    end
    
    % we store the old values of mu, Sigma just in case the log likelihood decreased and we need to return the last values before the singularity occurred
    muOld = mu;
    SigmaOld = Sigma;
    mu = mean(X);
    Sigma = cov(X);
    
    if(det(Sigma) <= 0)
        warning('Warning: Obtained Nonsingular Sigma.  Exiting with last reasonable parameters \n')
        model.mu = muOld; model.Sigma = SigmaOld;
        return;
    end
    
    % Convergence check
    prevLL = currentLL;
    XC = bsxfun(@minus, X, mu);
    currentLL = sum(-1/2*logdet(2*pi*Sigma) - 1/2*sum((XC/(Sigma)).*XC,2));
    loglikTrace(iter) = currentLL;
    if (currentLL < prevLL)
        warning('warning: EM did not increase objective.  Exiting with last reasonable parameters \n')
        mu = muOld;
        Sigma = SigmaOld;
    end
    if verbose, fprintf('%d: LL = %5.3f\n', iter, currentLL); end
    iter = iter + 1;
    converged = iter >=maxIter || (abs(currentLL - prevLL) / (abs(currentLL) + abs(prevLL) + eps)/2) < opttol;
end
model = struct('mu', mu, 'Sigma', Sigma);

end

