function index = subv2ind(siz,sub)
%SUBV2IND   Linear index from subscript vector.
% SUBV2IND(SIZ,SUB) returns an equivalent single index corresponding to a
% subscript vector for an array of size SIZ.
% If SUB is a matrix, with subscript vectors as rows, then the result is a 
% column vector.
%
% This is the opposite of IND2SUBV, so that
%   SUBV2IND(SIZ,IND2SUBV(SIZ,IND)) == IND.
%
% See also IND2SUBV, SUB2IND.

% Written by Tom Minka

prev_cum_size = [1 cumprod(siz(1:end-1))];
%index = (sub-1)*prev_cum_size' + 1;
index = sub*prev_cum_size' - sum(prev_cum_size) + 1;
