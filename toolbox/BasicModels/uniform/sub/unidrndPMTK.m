function r = unidrndPMTK(nstates, varargin)
%% Replacement function for the stats toolbox unidrnd function
% Sample from a uniform discrete distribution with nstates in 1:nstates
%%

% This file is from pmtk3.googlecode.com


if nargin < 2
    sz = [1 1];
elseif nargin == 2
    if isscalar(varargin{1})
        sz = [varargin{1}, 1];
    else
        sz = varargin{1};
    end
else
    sz = [varargin{:}];
end

r = ceil(nstates .* rand(sz));

end
