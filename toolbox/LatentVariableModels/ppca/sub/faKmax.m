function K = faKmax(D)
% Find max number of possible latnet dimensions in factor analysis
% to ensure identifiability, given D visible dimensions

% This file is from pmtk3.googlecode.com


% We solve D*(D+1)/2 - D*(K+1) + K*(K-1)/2 = 0 for K
K = D + 0.5 - 0.5*sqrt(8*D+1);


end
