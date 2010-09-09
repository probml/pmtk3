function sdgm = dgmSeqCreate(intra, inter, slice1CPDs, slice2CPDs, emission)
%% Create a sequential directed graphical model, (aka a dynamic Bayes net)
% *** work in progress ***
% To create the model you need only specify the two-slice dgm, (2TDBN) as 
% follows, and it will be automatically unrolled by e.g. dgmSeqFit or
% dgmSeqInferNodes.
%
% Currently there is only one inference method available. The sdgm is
% compiled down into an hmm, and then unpacked, use dgmSeqFit.
%
%% Inputs
%
% intra          - intra(i, j) = 1 iff there is an edge from i to j
%                  in time step t. Include all nodes explicitly, even if
%                  always observed. 
%
% inter          - inter(i, j) = 1 iff there is an edge from node i in time
%                  step t to node j in time step t+1. (Note emission
%                  restrictions below). 
%
% slice1CPDs     - a cell array of the tabularCpds, (see tabularCpdCreate)
%                  representing the discrete hidden nodes in the first time
%                  slice. The number of elements must equal
%                  (size(intra, 1) - 1): minus 1, since the last node is
%                  assumed to be the emission distribution. 
%
% slice2CPDs     - a cell array of tabularCpds representing the discrete
%                  hidden nodes in the second time slice. Set 
%                  slice2CPDs{i} = [] to use the slice1CPDs{i} params. 
%
% emission       - a structure storing the parameters of the emission
%                  distribution. There must be exactly one emission,
%                  (always observed) node per slice, with parameters tied
%                  across slices. Currently we do not support interslice
%                  connections to or from emission nodes, (i.e.
%                  autoregressive models).
%
%                  If discrete, emission has a single field T where
%                  T(a, b, ..., z) is the distribution of z given all 
%                  parents a, b, ...
%
%                  If continuous (Gaussian), emission has fields mu and
%                  Sigma, where mu is of size [d, ns(a), ns(b), ... ]
%                  and Sigma is of size [d, d, ns(a), ns(b), ...], where
%                  ns(a) denotes the number of states for parent a, etc. 
%                   
%            ** the last node in intra must be the (only) emission node **
%% Output
% 
% A struct that can be passed to e.g. dgmSeqFit, dgmSeqInferNodes,
% dgmSeqMap. 
%
%%

% This file is from pmtk3.googlecode.com

ndx = cellfun('isempty', slice2CPDs);
slice2CPDs(ndx) = slice1CPDs(ndx); 
sdgm = structure(intra, inter, slice1CPDs, slice2CPDs, emission); 
end


