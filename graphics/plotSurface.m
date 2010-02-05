function [h, p] = plotSurface(fn, xyRange, varargin)
% Plot the surface of the function evalatuated at xyRange = [xmin xmax ymin ymax]
% All other args (varargin) are passed directly to the surf function. 
% Returns, the plot handle h. 

    if nargin < 2
        xyRange = [-10 10 -10 10];
    end
    npoints = 100;
    [X1, X2] = meshgrid( linspace(xyRange(1), xyRange(2), npoints)', ...
                         linspace(xyRange(3), xyRange(4), npoints)'  );
    nr = size(X1, 1);  nc = size(X2, 1);
    p = reshape(fn([X1(:) X2(:)]), nr, nc);
    h = surf(X1, X2, p, varargin{:});    
end