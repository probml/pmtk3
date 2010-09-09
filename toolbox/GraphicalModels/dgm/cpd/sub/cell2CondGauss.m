function cpd = cell2CondGauss(C)
%% Convert a cell array of gauss models to a condGaussCpd

% This file is from pmtk3.googlecode.com


if isstruct(C) && isfield(C, 'cpdType'), cpd = C; return; end
nstates = numel(C); 
d = size(C{1}.Sigma, 1); 
mu = zeros(d, nstates); 
Sigma = zeros(d, d, nstates); 
for j=1:nstates
   mu(:, j) = colvec(C{j}.mu); 
   Sigma(:, :, j) = C{j}.Sigma;  
end
cpd = condGaussCpdCreate(mu, Sigma); 
end
