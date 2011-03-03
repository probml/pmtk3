function [TFmega, stateMap] = tabularFactorToMegaNode(TF, newId)
%% Construct a mega node from a tabularFactor 
% by taking the cartesian product of the state spaces of the participating
% variables. The new domain of TFmega is the single value newId. 
%
% The new states correspond to the linear indexing of TF.T.
%
% You can lookup the original states using stateMap
%
% Suppose TF.T is of size 2x2x2x2, then the following state combinations of
% the original variables correspond to the new states as follows. This was
% calculated using ind2subv([2 2 2 2], 1:16). 
%
%     1     1     1     1   -> 1
%     2     1     1     1   -> 2
%     1     2     1     1   -> 3
%     2     2     1     1   -> 4
%     1     1     2     1   -> 5
%     2     1     2     1   -> 6
%     1     2     2     1   -> 7
%     2     2     2     1   -> 8
%     1     1     1     2   -> 9
%     2     1     1     2   -> 10
%     1     2     1     2   -> 11
%     2     2     1     2   -> 12
%     1     1     2     2   -> 13
%     2     1     2     2   -> 14
%     1     2     2     2   -> 15
%     2     2     2     2   -> 16
%
%%

% This file is from pmtk3.googlecode.com

TFmega   = tabularFactorCreate(TF.T(:) , newId);
stateMap = ind2subv(size(TF.T), 1:numel(TF.T)); 
end
