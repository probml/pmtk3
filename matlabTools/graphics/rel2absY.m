function yabs = rel2absY(ypos, ax)
% See rel2absX

% This file is from pmtk3.googlecode.com

if nargin < 2
    ax = gca;
end
ylim = get(ax,'ylim');
ymin = ylim(1);
ymax = ylim(2);
yscale = ymax - ymin;
axAbs = get(ax,'Position');
yabs = axAbs(2) + ((ypos-ymin) ./ yscale).*axAbs(4);
end
