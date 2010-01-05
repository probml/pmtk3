function h = histp(x, xmin, xmax, nbins)
%HISTP	Histogram estimate of 1-dimensional probability distribution.
%
%	Description
%
%	HISTP(X, XMIN, XMAX, NBINS) takes a column vector X  of data values
%	and generates a normalized histogram plot of the  distribution. The
%	histogram has NBINS bins lying in the range XMIN to XMAX.
%
%	H = HISTP(...) returns a vector of patch handles.
%
%	See also
%	DEMGAUSS
%

%	Copyright (c) Ian T Nabney (1996-2001)

ndata = length(x);

bins = linspace(xmin, xmax, nbins);

binwidth = (xmax - xmin)/nbins;

num = hist(x, bins);

num = num/(ndata*binwidth);

h = bar(bins, num, 0.6);

