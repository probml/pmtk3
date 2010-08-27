function prior = makeGaussInvWishartDataDependentPrior(data, nmix)
%% Create a gaussInverseWishart prior for a mixGauss distribution
% that depends on the data
d = size(data, 2); 
prior.mu    = zeros(d, 1);
prior.k     = 0.01;
prior.dof   = d+2;
prior.Sigma = (1/nmix^(1/d))*var(data(:))*eye(d);
end