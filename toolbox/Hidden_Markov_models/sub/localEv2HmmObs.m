function Y = localEv2HmmObs(localev)
%% Convert data in localev format to hmm obs format
% The hmm format is an nobs-by-1 cell array of d-by-T(j) observations
% The localev format is a matrix of size nobs-by-d-max(T) potentially padded
% with nans. 
%
% See also hmmObs2LocalEv
%%

[nobs, d, Tmax] = size(localev); 
Y = cell(nobs, 1); 
for i=1:nobs
   O = squeeze(localev(i, :, :)); 
   O(:, any(isnan(O), 1)) = []; 
   Y{i} = O; 
end


end