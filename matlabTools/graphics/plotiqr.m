function plotiqr(X, varargin)
[annotate] = process_options(varargin, 'annotate', false);
sigma = std(X);
iqrplot = axes('Position', [0.1, 0.6, 0.8, 0.3]);
distplot = axes('Position', [0.1, 0.1, 0.8, 0.4]);
set(iqrplot,'YTick',[]);
switch class(X)
    case 'double'
        % Data is simply numeric

% This file is from pmtk3.googlecode.com

        axes(distplot);
        ksdensity(X);
        
        quants = quantilePMTK(X, [0.25, 0.50, 0.75]);
        % [Q1, med, Q3] = quantile(X, [0.25, 0.50, 0.75]); Again, does not work
        % iqr = Q3 - Q1;
        
        %line([quants(1), quants(3); quants(1), quants(3)], [0.2,0.8; 0.2,0.8]); % median
        %line([quants(1), quants(1); quants(3), quants(3)], [0.2,0.2; 0.2,0.8]); % top
        %line([quants(1), quants(3); quants(1), quants(3)], [0.2,0.8; 0.2,0.8]); % bottom
        %line([quants(1), quants(3); quants(1), quants(3)], [0.2,0.8; 0.2,0.8]); % left
        %line([quants(1), quants(3); quants(1), quants(3)], [0.2,0.8; 0.2,0.8]); % right
        
    otherwise
        % We assume that it is a distribution that supports the plot method
        % otherwise
        plot(X)
        error('No general support to find inverse cdf in distribution objects.  Quitting');
        %quants = cdf(X, [0.25, 0.50, 0.75]);
        
end
lim = axis;
xmin = lim(1);
xmax = lim(2);
% [xmin, xmax] = [lim(1), lim(2)]; This does not work for some reason

axes(iqrplot);
iqr = quants(3) - quants(1);
% set the axis limits
axis([min(xmin, quants(1) - 1.5*iqr - sigma), max(xmax, quants(3) + 1.5*iqr + sigma), 0, 1.5]);
% plot the median
line([quants(2), quants(2)], [0.2, 0.8]);
% plot the box for the IQR: top, bottom, left, right, median
boxX = [quants(1), quants(1), quants(1), quants(3), quants(2);
    quants(3), quants(3), quants(1), quants(3), quants(2)];
top = 0.8; bottom = 0.2; middle = 0.5;
boxY = [top, bottom, top, top, top;
    top, bottom, bottom, bottom, bottom];
offset = 0.1;
line(boxX, boxY, 'color', 'black');
% Now the iqr line

iqrX = [quants(1) - 1.5*iqr, quants(1) - 1.5*iqr, quants(3) + 1.5*iqr;
    quants(3) + 1.5*iqr quants(1) - 1.5*iqr, quants(3) + 1.5*iqr];
iqrY = [middle, middle + offset, middle + offset;
    middle, middle - offset, middle - offset];
line(iqrX, iqrY, 'color', 'black');

% Now text
if(annotate)
    text(quants(2) - offset, bottom - offset, 'median');
    text(quants(1), top + offset, 'Q1');
    text(quants(3), top + offset, 'Q3');
    text(quants(2), top + 3*offset, 'IQR');
    text(quants(1) - 1.2*iqr, middle + offset, 'Q1 - 1.5*IQR');
    text(quants(3) + 1.5*iqr, middle + offset, 'Q3 + 1.5*IQR');
    
    iqrXnote = [quants(1), quants(1), quants(3);
        quants(3), quants(1), quants(3)];
    iqrYnote = [top + 2*offset, top + 5/2*offset, top + 5/2*offset;
        top + 2*offset, top + 3/2*offset, top + 3/2*offset];
    line(iqrXnote, iqrYnote, 'color', 'black');
    
end


end
