function fg = dgmToFactorGraph(dgm)
%% Convert a dgm to a factorGraph
%
%%

% This file is from pmtk3.googlecode.com

fg = mrfToFactorGraph(dgmToMrf(dgm)); 

% 
% if ~isfield(dgm, 'factors')
%    factors = cpds2Factors(dgm.cpds); 
% else
%     factors = dgm.factors;
% end
% fg = factorGraphCreate(factors, dgm.nstates); 
end
