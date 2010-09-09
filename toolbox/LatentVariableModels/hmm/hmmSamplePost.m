function [samples] = hmmSamplePost(model, X, nsamples, varargin)
% Forwards filtering, backwards sampling for HMMs
%
% X must be a single sequence of size d-by-T
% OUTPUT:
% samples(t,s) = value of S(t)  in sample s
%%

% This file is from pmtk3.googlecode.com

softev = process_options(varargin, 'softev', []);
initDist = model.pi;
transmat = model.A;
if isempty(softev)
    logB = mkSoftEvidence(model.emission, X);
    softev = exp(logB); 
end
[K T] = size(softev);
[loglik, alpha] = hmmFilter(initDist, transmat, softev);
samples = zeros(T, nsamples);
dist = normalize(alpha(:,T));
samples(T,:) = sampleDiscrete(dist, 1,nsamples);
for t=T-1:-1:1
    tmp = softev(:,t+1) ./ (alpha(:,t+1)+eps); % b_{t+1}(j) / alpha_{t+1}(j)
    xi_filtered = transmat .* (alpha(:,t) * tmp');
    for n=1:nsamples
        dist = normalize(xi_filtered(:,samples(t+1,n)));
        samples(t,n) = sampleDiscrete(dist);
    end
end


end
