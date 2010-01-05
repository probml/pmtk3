function [h1, h2] = mlphint(net);
%MLPHINT Plot Hinton diagram for 2-layer feed-forward network.
%
%	Description
%
%	MLPHINT(NET) takes a network structure NET and plots the Hinton
%	diagram comprised of two figure windows, one displaying the first-
%	layer weights and biases, and one displaying the second-layer weights
%	and biases.
%
%	[H1, H2] = MLPHINT(NET) also returns handles H1 and  H2 to the
%	figures which can be used, for instance, to delete the  figures when
%	they are no longer needed.
%
%	To print the figure correctly, you should call SET(H,
%	'INVERTHARDCOPY', 'ON') before printing.
%
%	See also
%	DEMHINT, HINTMAT, MLP, MLPPAK, MLPUNPAK
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

wb1 = [net.w1; net.b1];
[xvals, yvals, color] = hintmat(wb1');
% Try to preserve aspect ratio approximately
if (8*net.nhidden < 6*(net.nin + 1))
  delx = xmax; dely = xmax*net.nhidden/(net.nin + 1);
else
  delx = ymax*(net.nin + 1)/net.nhidden; dely = ymax;
end

h1 = figure('Color', [0.5 0.5 0.5], ...
  'Name', 'Hinton diagram: first-layer weights and biases', ...
  'NumberTitle', 'off', ...
  'Colormap', [0 0 0; 1 1 1], ...
  'Units', 'pixels', ...
  'Position', [x01 y01 delx dely]);
set(gca, 'Visible', 'off', 'Position', [0 0 1 1]);
hold on

cmap = [0 0 0; 1 1 1];
colors(1, :, :) = cmap(color, :);
patch(xvals', yvals', colors, 'Edgecolor', 'none');
axis equal;
xpos = net.nin;
line([xpos xpos], [0 net.nhidden], 'color', 'red', 'linewidth', 3);

% Second layer

wb2 = [net.w2; net.b2];
[xvals, yvals, color] = hintmat(wb2');
if (8*net.nout < 6*(net.nhidden + 1))
  delx = xmax; dely = xmax*net.nout/(net.nhidden + 1);
else
  delx = ymax*(net.nhidden + 1)/net.nout; dely = ymax;
end

h2 = figure('Color', [0.5 0.5 0.5], ...
  'Name', 'Hinton diagram: second-layer weights and biases', ...
  'NumberTitle', 'off', ...
  'Colormap', [0 0 0; 1 1 1], ...  
  'Units', 'pixels', ...
  'Position', [x02 y02 delx dely]);
set(gca, 'Visible', 'off', 'Position', [0 0 1 1]);

hold on
colors2(1, :, :) = cmap(color, :);
patch(xvals', yvals', colors2, 'Edgecolor', 'none');
axis equal;
xpos = net.nhidden;
line([xpos xpos], [0 net.nout], 'color', 'red', 'linewidth', 3);

