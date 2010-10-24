function Tbig = bsxTable(fn, Tbig, Tsmall, bigdom, smalldom)
%% Apply a binary function to two multidimensional vectors using bsxfun
% reshaping and virtually expanding the smaller table as needed
%
% The tables are matched up according to smalldom and bigdom
% smalldom must be a subset (but not necessarily a subsequence) of bigdom
%
%
%%

% This file is from pmtk3.googlecode.com

smallsz = sizePMTK(Tsmall);
if isequal(bigdom, smalldom)
    Tbig = fn(Tbig, Tsmall);
else
    nbig    = numel(bigdom);
    ndx     = lookupIndices(smalldom, bigdom);
    sz      = ones(1, nbig);
    sz(ndx) = smallsz;
    Tsmall  = reshape(Tsmall, [sz 1]);
    Tbig    = bsxfun(fn, Tbig, Tsmall);
end
end
