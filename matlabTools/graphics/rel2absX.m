function xabs = rel2absX(xpos, ax)
% Convert from axis-relative coordinates to absolute coordinates within the
% figure. See also rel2absY.

% This file is from pmtk3.googlecode.com

if nargin < 2, 
    ax = gca;
end
xlim = get(ax,'xlim');
xmin = xlim(1);
xmax = xlim(2);
xscale = xmax - xmin;
axAbs = get(ax,'Position');
xabs = axAbs(1) + ((xpos-xmin) ./ xscale).*axAbs(3);
end

