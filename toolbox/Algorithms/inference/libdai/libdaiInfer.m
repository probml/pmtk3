function [logZ, nodeBels, clqBels, cliqueLookup] = libdaiInfer(tfacs, varargin)
%% Bare bones interface to libdai
% 
%% Input
%
% tfacs    - a cell array of tabular factors
% varargin - all other args are passed directly to dai
%
%% Outputs
%
% logZ     - log of the partition sum
%
% nodeBels - all single marginals (node beliefs)
%
% clqBels  - all of the clique beliefs
%
% cliqueLookup - an nvars-by-ncliques lookup table
%%

% This file is from pmtk3.googlecode.com

if ~libdaiInstalled
    error('could not find dai.%s - need to install libdai', mexext); 
end

psi = cellfuncell(@convertToLibFac, tfacs);
%[logZ, clqBels, maxDiff, nodeBels, facBels, map] = dai(psi, varargin{:}); %#ok
[logZ, clqBels, maxDiff, nodeBels, facBels] = dai(psi, varargin{:}); %#ok

if nargout > 1
    nodeBels = cellfuncell(@convertToPmtkFac, nodeBels);
end
if nargout > 2
    clqBels = cellfuncell(@convertToPmtkFac, clqBels);
end
if nargout > 3
    clqStruct = [clqBels{:}];
    nvars = max([clqStruct.domain]);
    nclqs = numel(clqBels); 
    cliqueLookup = zeros(nvars, nclqs); 
    for c=1:nclqs
        cliqueLookup(clqBels{c}.domain, c) = 1; 
    end
end
end


function mfac = convertToPmtkFac(lfac)
% Convert a libdai factor to PMTK format.
mfac = tabularFactorCreate(lfac.P, lfac.Member+1);
end

function lfac = convertToLibFac(mfac)
% Convert a PMTK factor to libdai format
assert(~isempty(mfac));   % can happen if we are slicing
domain = mfac.domain;
T = mfac.T; 
try
assert(~isempty(domain)); 
assert(numel(T) > 1);      % does not support trival factors
assert(any(T(:)));         % does not support all zero factors
assert(~isrowvec(T));      % crashes with row vectors
catch %#ok
   disp(mfac);
   error('libdaiJtree:invalidFactor', 'invalid factor');
end

lfac.Member = domain - 1;
lfac.P = T;
end
