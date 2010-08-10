function ess = condGaussCpdComputeEss(cpd, data, weights, B)
%% Compute the expected sufficient statistics for a condGaussCpd
% data is nobs-by-d
% weights is nobs-by-nstates; the marginal probability of the discrete
% parent for each observation. 
% B is ignored, but required by the interface, (since mixture emissions use
% it). 
%%
d       = cpd.d; 
nstates = cpd.nstates; 
wsum    = sum(weights, 1);
xbar    = bsxfun(@rdivide, data'*weights, wsum); %d-by-nstates
XX      = zeros(d, d, nstates);
for j=1:nstates
    Xc          = bsxfun(@minus, data, xbar(:, j)');
    XX(:, :, j) = bsxfun(@times, Xc, weights(:, j))'*Xc;
end
ess = structure(xbar, XX, wsum); 
end
