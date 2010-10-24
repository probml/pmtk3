function [h,p] = plotDistribution(logprobFn, varargin)
%% Plot a density function in 2d 
% handle = plot(logprobFn, 'name1', val1, 'name2', val2, ...) 
%
% '-xrange'      - [xmin xmax] for 1d or [xmin xmax ymin ymax] for 2d 
% '-useLog'      - true to plot log density, default false 
% '-plotArgs'    - args to pass to the plotting routine, default {} 
% '-useContour'  - true to plot contour, false (default) to plot surface 
% '-npoints'     - number of points in each grid dimension (default 50) 
% '-scaleFactor' - i.e. mixing weight, a scalar factor applied to
%                  prob/logprob depending on '-useLog'
% '-ndimensions' - number of dimensions, 1 or 2, (default 2)
% eg. plot(@(X)logprob(X, mu, Sigma), '-useLog', true, '-plotArgs', {'ro-', 'linewidth',2})

% This file is from pmtk3.googlecode.com

    
    [xrange, useLog, plotArgs, useContour, npoints, scaleFactor, ndimensions] = ...
    process_options(varargin, 'xrange'     , [-10 10 -10 10]  ,...
                              'useLog'     , false      ,...
                              'plotArgs'   ,{}          ,...
                              'useContour' , true       ,...
                              'npoints'    , 100        ,...
                              'scaleFactor', 1          ,...
                              'ndimensions', 2);
    
    plotArgs = cellwrap(plotArgs); 
    if ndimensions == 1
        xs = linspace(xrange(1), xrange(2), npoints);
        p = logprobFn(xs(:));
        if ~useLog
            p = exp(p);
        end
        p = p*scaleFactor;
        h = plot(colvec(xs), colvec(p), plotArgs{:});
    else
        [X1, X2] = meshgrid( linspace(xrange(1), xrange(2), npoints)', ...
                             linspace(xrange(3), xrange(4), npoints)'  );
        [nr] = size(X1, 1); 
        nc = size(X2, 1);
        X = [X1(:) X2(:)];
        p = logprobFn(X);
        if ~useLog
            p = exp(p);
        end
        p = reshape(p, nr, nc);
        if useContour
            if~(any(isnan(p)))
                [c, h] = contour(X1, X2, p, plotArgs{:});
            end
        else
            h = surf(X1, X2, p, plotArgs{:});
        end
    end
end
