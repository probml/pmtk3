function model = betaBinomCreate(a, b, N)
%% Construct a betaBinom distribution
%PMTKdefn $\int binom(x | n,\theta) betadist(\theta |a, b) d\theta$
%%

% This file is from pmtk3.googlecode.com

model = structure(a, b, N); 

end
