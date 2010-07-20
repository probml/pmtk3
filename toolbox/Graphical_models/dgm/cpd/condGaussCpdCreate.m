function CPD = condGaussCpdCreate(mu, Sigma, varargin)
%% Create a conditional Gaussian distribution for use in a DGM
%
% mu is a matrix of size d-by-nstates
% Sigma is of size d-by-d-by-nstates
%
% 'prior' is a Gauss-inverseWishart distribution, namely, a struct with
% fields  mu, Sigma, dof, k
% Set 'prior' to 'none' to do mle. 
%%

prior = process_options(varargin, 'prior', []); 
d = size(Sigma, 1); 
if isempty(prior) 
      prior.mu    = zeros(1, d);
      prior.Sigma = 0.1*eye(d);
      prior.k     = 0.01;
      prior.dof   = d + 1; 
end
if isvector(Sigma)
   Sigma = permute(rowvec(Sigma), [1 3 2]);  
end
nstates = size(Sigma, 3); 
if size(mu, 2) ~= nstates && size(mu, 1) == nstates
    mu = mu';
end
CPD = structure(mu, Sigma, nstates, d, prior); 
CPD.cpdType = 'condGauss'; 
CPD.fitFn = @condGaussCpdFit; 

end