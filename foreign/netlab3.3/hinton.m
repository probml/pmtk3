function h = hinton(w);
%HINTON	Plot Hinton diagram for a weight matrix.
%
%	Description
%
%	HINTON(W) takes a matrix W and plots the Hinton diagram.
%
%	H = HINTON(NET) also returns the figure handle H which can be used,
%	for instance, to delete the  figure when it is no longer needed.
%
%	To print the figure correctly in black and white, you should call
%	SET(H, 'INVERTHARDCOPY', 'OFF') before printing.
%
%	See also
%	DEMHINT, HINTMAT, MLPHINT
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Set scale to be up to 0.9 of maximum absolute weight value, where scale
% defined so that area of box proportional to weight value.

% Use no more than 640x480 pixels
xmax = 640; ymax = 480;

% Offset bottom left hand corner
x01 = 40; y01 = 40;
x02 = 80; y02 = 80;

% Need to allow 5 pixels border for window frame: but 30 at top
border = 5;
top_border = 30;

ymax = ymax - top_border;
xmax = xmax - border;

% First layer

[xvals, yvals, color] = hintmat(w);
% Try to preserve aspect ratio approximately
if (8*size(w, 1) < 6*size(w, 2))
  delx = xmax; dely = xmax*size(w, 1)/(size(w, 2));
else
  delx = ymax*size(w, 2)/size(w, 1); dely = ymax;
end

h = figure('Color', [0.5 0.5 0.5], ...
  'Name', 'Hinton diagram', ...
  'NumberTitle', 'off', ...
  'Colormap', [0 0 0; 1 1 1], ...
  'Units', 'pixels', ...
  'Position', [x01 y01 delx dely]);
set(gca, 'Visible', 'off', 'Position', [0 0 1 1]);
hold on
patch(xvals', yvals', color', 'Edgecolor', 'none');
axis equal;

