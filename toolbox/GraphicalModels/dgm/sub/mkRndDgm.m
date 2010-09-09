function dgm = mkRndDgm(nnodes, maxFanIn, maxFanOut, maxNstates, sparsityFactor, varargin)
%% Create a random dgm

% This file is from pmtk3.googlecode.com


SetDefaultValue(1, 'nnodes', 10);
SetDefaultValue(2, 'maxFanIn', 2);
SetDefaultValue(3, 'maxFanOut', 2);
SetDefaultValue(4, 'maxNstates', 2);
SetDefaultValue(5, 'sparsityFactor', 0.1); 


G = mkRndDag(nnodes, maxFanIn, maxFanOut, sparsityFactor); 
ns = unidrndPMTK(maxNstates-1, [nnodes, 1])'+1; % rand # states from 2 to maxNstates
CPDs = cell(nnodes, 1); 
for i=1:nnodes
   dom     = [parents(G, i), i]; 
   sz      = [ns(dom), 1]; 
   T       = rand(sz);
   T       = mkStochastic(T); 
   CPDs{i} = tabularCpdCreate(T); 
end
dgm = dgmCreate(G, CPDs, varargin{:}); 


end


