function CPD = condGaussCpdCreate(mu, Sigma)
%% Create a conditional Gaussian distribution for use in a DGM
%
% mu is a matrix of size d-by-nstates
% Sigma is of size d-by-d-by-nstates
%%

nstates = size(Sigma, 3); 
if size(mu, 2) ~= nstates && size(mu, 1) == nstates
    mu = mu';
end
d = size(Sigma, 1); 
CPD = structure(mu, Sigma, nstates, d); 
CPD.cpdType = 'condGauss'; 


end