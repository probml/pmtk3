%% Example from Neapolitan's book "Learning Bayesian networks" p438
%
%%

% This file is from pmtk3.googlecode.com

X = [1 1; 1 2; 1 1; 2 2; 1 1; 2 1; 1 1; 2 2];

alpha = 4;
Gs = { [0 1; 0 0], [0 0; 0 0] };
for i=1:length(Gs)
   G = Gs{i};
   L(i) = discreteDAGlogEv(X, G, alpha);
   p(i) = exp(L(i));
end
post = exp(normalizeLogspace(L))
