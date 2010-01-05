%Convert from axis-relative coordinates to absolute coordinates within the
%figure. 
function xabs = rel2absX(xpos)
    ax = gca;
    xlim = get(ax,'xlim');
    xmin = xlim(1);
    xmax = xlim(2);
    xscale = xmax - xmin;
    axAbs = get(ax,'Position');
    xabs = axAbs(1) + ((xpos-xmin) ./ xscale).*axAbs(3);
end

