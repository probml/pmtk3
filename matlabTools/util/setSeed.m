function setSeed(seed)
% Set the random seed
% We don't use the new RandStream class for compatibility with Octave and
% older versions of Matlab. In the future it may be necessary to test the
% Matlab version and call the appropriate code. 

% This file is from pmtk3.googlecode.com

global RNDN_STATE  RND_STATE
if nargin == 0
    seed = 0; 
end
warning('off', 'MATLAB:RandStream:ReadingInactiveLegacyGeneratorState');
RNDN_STATE = randn('state');  %#ok<*RAND>
randn('state', seed);
RND_STATE = rand('state');
rand('twister', seed);
end
