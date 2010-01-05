function seed = randomseed(seed)
% RANDOMSEED   Get or set the random seed.
% SEED = RANDOMSEED returns the current random seed for lightspeed random 
% number routines.  SEED is a vector of 3 integers.
% RANDOMSEED(NEW_SEED) sets a new random seed.
% The seed determines the sequence of numbers that will be generated.
% Only the routines randgamma, randbinom, and sample_hist are affected.
%
% Example:
% randomseed([4 5 6])
% randgamma(repmat(3,1,3))   % 3 random numbers
% randomseed([4 5 6])
% randgamma(repmat(3,1,3))   % the same 3 numbers

error('You must first run install_lightspeed.m');
