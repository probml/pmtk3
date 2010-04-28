function setSeed(seed)

if nargin == 0; seed = 0; end
global RNDN_STATE  RND_STATE

warning('off', 'MATLAB:RandStream:ReadingInactiveLegacyGeneratorState');
RNDN_STATE = randn('state');
randn('state',seed);
RND_STATE = rand('state');
%rand('state',seed);
rand('twister',seed);

warning('on', 'MATLAB:RandStream:ReadingInactiveLegacyGeneratorState');
end