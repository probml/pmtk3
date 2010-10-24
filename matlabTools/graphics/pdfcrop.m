function pdfcrop(h,hborder,vborder)
%Make the paper size, the same as the figure size, (plus an optional
%border). This is important when exporting figures to pdf for inclusion in
%latex for example. 
%
%h is the handle to the current figure and is returned by the matlab figure
%command as in 'h = figure;' when a new figure is created, or by the 'gcf'
%command, which returns the current figure. If it is not specified, h is
%set to the current figure. You can also specify an optional white border
%in inches by specifying values for the horizontal border, hborder, and the
%vertical border, vborder). 
%
%'hborder' The horizontal border, (default = 0.1 inches)
%'vborder' the vertical border, (default = 0.1 inches)
%
%%

% This file is from pmtk3.googlecode.com

    
    if(nargin <= 1)
        hborder = 0.1; vborder = 0.1;
    end
    if(nargin == 0);h = gcf;end
    if ~ishandle(h); return; end
    set(h,'Units','inches');
    pos = get(h,'Position');
    width = pos(3) + hborder;
    height = pos(4) + vborder;
    set(h,'PaperSize',[width,height]);
    set(h,'PaperPositionMode','auto');

end
