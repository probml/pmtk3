function [model, dataSamples, LL] = gaussMissingFitGibbs(data, varargin)
% Perform gibbs sampling for the missing values of a data matrix
% Algorithm consists of a stochastic imputation stage (sampling from conditional given known)
% and then sampling from the resulting posterior for mu and Sigma given the current state of the samples
% Optional arguments and their defaults:
% (mu0, Lambda0, k0, dof) [nanmeanPMTK(data), diag(nanvarPMTK(data)), 0.01, size(data,2) + 2] - Parameters defining the NIW prior
% nSamples [600] - the number of samples to run the algorithm for
% nburnin [100] - how many samples are considered burnin?
% verbose [false]
%PMTKauthor Cody Severinski, Kevin Murphy

% This file is from pmtk3.googlecode.com


[mu0, Lambda0, k0, dof, nSamples, nburnin, verbose] = process_options(varargin, ...
    'mu0', [], 'Lambda0', [], 'k0', 0.01, 'dof', [], 'nSamples', 600, 'nburnin', 100, 'verbose', false);

allMissing = find(all(isnan(data),2));
data = data(setdiffPMTK(1:size(data,1), allMissing),:); % samples with all missing values are useless;

[n,d] = size(data);
dataMissing = isnan(data);
missingRows = any(dataMissing,2);
missingRows = find(missingRows == 1);  % rows with at least one dimension missing

% defaults
if(isempty(mu0))
    mu0 = nanmeanPMTK(data);
end
if(isempty(Lambda0))
    Lambda0 = diag(nanvarPMTK(data));
end
if(isempty(dof))
    dof = d + 2;
end
dataSamples = zeros([size(data), nSamples - nburnin]);
muSamples = zeros(nSamples - nburnin, d);
SigmaSamples = zeros(d,d,nSamples);
LL = zeros(nSamples - nburnin, 1);

allFine = setdiffPMTK(1:n, missingRows);
imputeRows = missingRows(:)';

xCurr = zeros(size(data));
xCurr(allFine,:) = data(allFine,:);
for i=imputeRows
    u = dataMissing(i,:); o = ~u;
    xCurr(i,o) = data(i,o);
end

%SigmaCurr = iwishrnd(Lambda0, dof);
SigmaCurr = invWishartSample(struct('Sigma', (Lambda0), 'dof', k0+n));
model.mu = mu0; model.Sigma = SigmaCurr / k0;
muCurr = gaussSample(model);
if(~isempty(missingRows))
    for s=1:nSamples
        if(s > nburnin)
            dataSamples(allFine,:,s - nburnin) = data(allFine,:);
        end
        
        for i=imputeRows
            u = dataMissing(i,:); %unobserved
            o = ~u; %observed
            SooCurrinv = inv(SigmaCurr(o,o));
            muCond = muCurr(u) + (SigmaCurr(u,o)*SooCurrinv*((data(i,o)-muCurr(o))'))';
            varCond = SigmaCurr(u,u) - SigmaCurr(u,o) * SooCurrinv * SigmaCurr(o,u);
            
            try
                model.mu = muCond; model.Sigma = varCond;
                xSample = gaussSample(model); % Sample the unobserved
            catch ME
                varCond = roundto(varCond, sqrt(eps));
                xSample = gaussSample(muCond, varCond);
            end
            xCurr(i,u) = xSample;
        end
        if(s > nburnin)
            dataSamples(:,:,s - nburnin) = xCurr;
        end
        
        % Now done imputing.  Sample from the posterior
        xbar = mean(xCurr);
        muPost = (n*xbar + k0*mu0) / (n + k0);
        LambdaPost = Lambda0 + n*cov(xCurr,1) + n*k0/(n+k0) * (xbar - mu0)*(xbar - mu0)';
        %SigmaCurr = iwishrnd(LambdaPost, k0 + n);
        SigmaCurr = invWishartSample(struct('Sigma', LambdaPost, 'dof', k0+n));
        model.mu = muPost; model.Sigma = SigmaCurr/ (k0 + n);
        muCurr = gaussSample(model);
        if(s > nburnin)
            muSamples(s - nburnin,:) = muCurr;
            SigmaSamples(:,:,s - nburnin) = SigmaCurr;
            XC = bsxfun(@minus,xCurr,muCurr);
            lik = sum(-1/2*logdet(2*pi*SigmaCurr) - 1/2*sum((XC/SigmaCurr).*XC,2));
            LL(s - nburnin) = - dof*d/2*log(2) - mvtGammaln(d, dof/2) + dof/2*logdet(Lambda0) - (dof + d + 1)/2*logdet(SigmaCurr) - 1/2*trace(Lambda0/(SigmaCurr)) ...
                -1/2*logdet(2*pi*SigmaCurr/k0) - k0/2*((muCurr - mu0)/SigmaCurr)*(muCurr - mu0)' + lik;
            if verbose, fprintf('%d: LL = %5.3f\n', s - nburnin, LL(s - nburnin)); end
        end
        
    end
else
    warning('No missing data to impute')
    model.mu = []; model.Sigma = []; dataSamples = [];
end
model.mu = muSamples; model.Sigma = SigmaSamples;

end
