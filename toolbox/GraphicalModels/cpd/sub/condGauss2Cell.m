function C = condGauss2Cell(condGaussCpd)
%% Convert a condGaussCpd to a cell array of gauss structs, one per state.

% This file is from pmtk3.googlecode.com

if iscell(condGaussCpd), C = condGaussCpd; return; end
mu = condGaussCpd.mu;
Sigma = condGaussCpd.Sigma;
nstates = condGaussCpd.nstates;
C = cell(nstates, 1); 
for j=1:nstates
    C{j} = gaussCreate(mu(:, j), Sigma(:, :, j)); 
end
end
