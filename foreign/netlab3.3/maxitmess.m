function s = maxitmess()
%MAXITMESS Create a standard error message when training reaches max. iterations.
%
%	Description
%	S = MAXITMESS returns a standard string that it used by training
%	algorithms when the maximum number of iterations (as specified in
%	OPTIONS(14) is reached.
%
%	See also
%	CONJGRAD, GLMTRAIN, GMMEM, GRADDESC, GTMEM, KMEANS, OLGD, QUASINEW, SCG
%

%	Copyright (c) Ian T Nabney (1996-2001)

s = 'Maximum number of iterations has been exceeded';

