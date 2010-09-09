function r = unifrndPMTK(a, b, varargin)
%% Replacement for the stats unifrnd function 
% Just samples uniformly between a and b

% This file is from pmtk3.googlecode.com

if nargin < 3
    sz = [1, 1];
elseif nargin == 3
    if isscalar(varargin{1})
        sz = [varargin{1}, 1];
    else
        sz = varargin{1};
    end
else
    sz = [varargin{:}];
end
r = a+(b-a)*rand(sz); 
end
