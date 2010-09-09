function [consistent, kappa] = irrepIndex(Sigma, w)
% Sigma is a covariance matrix, w is a dx1 weight vector
% Let J be the relevant variables, Jc be the irrelevant
% The data generator is sign consistent iff
% ||(S_{J^c,J})*(S_{J,J}^-1)*sign(W_J)||_inf <= 1

% This file is from pmtk3.googlecode.com


rel = find(abs(w) > 0);
irrel = find(w==0);
kappa = norm(Sigma(irrel,rel)*inv(Sigma(rel,rel))*sign(w(rel)), inf);
consistent = (kappa <= 1);


end
