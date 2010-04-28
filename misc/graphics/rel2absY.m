%See rel2absX
function yabs = rel2absY(ypos)
    ax = gca;
    ylim = get(ax,'ylim');
    ymin = ylim(1);
    ymax = ylim(2);
    yscale = ymax - ymin;
    axAbs = get(ax,'Position');
    yabs = axAbs(2) + ((ypos-ymin) ./ yscale).*axAbs(4);
end
  