function cpd = condGaussCpdFit(cpd, Z, Y)
%% Fit a conditional Gaussian CPD
% Z(i) is the state of the parent Z in observation i.
% Y(i, :) is the ith 1-by-d observation of the child corresponding to Z(i)
% 
% By default we lightly regularize the parameters so we are doing map
% estimation, not mle. The Gauss-invWishart prior is set by 
% condGaussCpdCreate. 
%
%  cpd.mu is a matrix of size d-by-nstates
%  cpd.Sigma is of size d-by-d-by-nstates
%%
d = cpd.d; 
Z = colvec(Z); 
prior = cpd.prior; 
nstates = cpd.nstates; 
if ~isstruct(prior) || isempty(prior) % do mle
    cpd.mu    = partitionedMean(Y, Z, nstates)';
    cpd.Sigma = partitionedCov(Y, Z,  nstates); 
else  % map
    mu = zeros(d, nstates);
    Sigma = zeros(d, d, nstates);
    for s = 1:nstates
        m              = gaussFit(Y(Z == s, :), prior);
        mu(:, s)       = m.mu(:);
        Sigma(:, :, s) = m.Sigma;
    end
    cpd.mu = mu;
    cpd.Sigma = Sigma; 
end
   
end