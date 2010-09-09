function S = dgmSample(dgm, nsamples)
%% Sample from a dgm
% Does not support evidence yet, and currenly only supports tabularCPDs
% Each *row* of S is a sample
%%

% This file is from pmtk3.googlecode.com

if nargin < 2, nsamples = 1; end
G = dgm.G; 
CPDs = dgm.CPDs; 
order = toposort(G); 
S = zeros(nsamples, dgm.nnodes);
for i=1:nsamples
    for j = order
        ps = S(i, parents(G, j));
        S(i, j) = tabularCpdSample(CPDs{j}, ps);
    end
end
end
