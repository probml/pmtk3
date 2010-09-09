function localev = hmmObs2LocalEv(obs)
%% Convert observation data in hmm format, to localev format
% The hmm format is an nobs-by-1 cell array of d-by-T(j) observations
% The localev format is a matrix of size nobs-by-d-max(T) potentially padded
% with nans. 
%
% See also localEv2HmmObs
%%

% This file is from pmtk3.googlecode.com

obs = cellwrap(obs);
nobs = numel(obs); 
d    = size(obs{1}, 1); 
Tmax = max(cellfun(@(c)size(c, 2), obs)); 
localev = nan(nobs, d, Tmax);

for i=1:numel(obs)
   O = obs{i}; 
   t = size(O, 2); 
   localev(i, :, 1:t) = O; 
end
end
