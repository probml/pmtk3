function hh = plotmarkers(h, marker, col, frac)
% add the specified marker to the figure handle at a sparse set (frac) of locations
% Example usage
%figure(1); clf
%h1 = plot(1:1000, 'k-', 'linewidth', 3); hold on
%hh1 = plotmarkers(h1, 'o')
%h2 = plot(1000:-1:1, '-');
%hh2 = plotmarkers(h2, 's', [1 0.5 0.25], 0.05)
%legend([hh1, hh2], {'foo', 'bar'})

% This file is from pmtk3.googlecode.com



if nargin < 3, col = 'k'; end
if nargin < 4, frac = 0.01; end
style = '-';

obj=get(h);
n = length(obj.XData);
ndx = ceil(linspace(1,n,frac*n));
hold on
%hh = plot(obj.XData(ndx), obj.YData(ndx), 'linestyle', style, 'color', col, 'marker', marker);
hh = plot(obj.XData(ndx), obj.YData(ndx), '.', 'color', col);
set(hh, 'marker', marker, 'markersize', 12);


end
