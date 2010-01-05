function fh=conffig(y, t)
%CONFFIG Display a confusion matrix.
%
%	Description
%	CONFFIG(Y, T) displays the confusion matrix  and classification
%	performance for the predictions mat{y} compared with the targets T.
%	The data is assumed to be in a 1-of-N encoding, unless there is just
%	one column, when it is assumed to be a 2 class problem with a 0-1
%	encoding.  Each row of Y and T corresponds to a single example.
%
%	In the confusion matrix, the rows represent the true classes and the
%	columns the predicted classes.
%
%	FH = CONFFIG(Y, T) also returns the figure handle FH which  can be
%	used, for instance, to delete the figure when it is no longer needed.
%
%	See also
%	CONFMAT, DEMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)

[C, rate] = confmat(y, t);

fh = figure('Name', 'Confusion matrix', ...
  'NumberTitle', 'off');

plotmat(C, 'k', 'k', 14);
title(['Classification rate: ' num2str(rate(1)) '%'], 'FontSize', 14);
