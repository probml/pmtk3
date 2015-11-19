function h = plotClassProb(X, Y, predictFcn, varargin)
% Plot probability assigned to each class for a 2d grid
% This is a hacked version of plotDecisionBoundary.
%
% X          - an n-by-2 data matrix
% Y          - an n-by-1 matrix of class labels
% predictFcn - a handle to a function of the form yhat = predictFcn(Xtest)

%%

% This file is from pmtk3.googlecode.com

    [stipple     , colors   , symbols,   markersize     , ...
     markerLineWidth, contourProps, newFigure, resolution] = ...
        process_options( varargin                       , ...
        'stipple'      , true                           , ...
        'colors'       , pmtkColors()                   , ...
        'symbols'      , '+ovd*.xs^d><ph'               , ...
        'markerSize'   , 8                              , ...
        'markerLineWidth', 2                            , ...
        'contourProps' , {'LineWidth', 2, 'LineColor', 'k'} , ...
        'newFigure'    , true                           , ...
        'resolution'   , 300);
    
    nclasses = nunique(Y);
    range = dataWindow(X);
    [X1grid, X2grid, yhat, phat] = gridPredict(range, resolution, predictFcn);
    [nrows, ncols] = size(X1grid);
    nclasses = min(nclasses, size(phat, 2)); % if binary, nclasses=1
    h = zeros(nclasses, 1);
    for c=1:nclasses
      phatGrid_c = reshape(phat(:,c), nrows, ncols);
      figure; imagesc(phatGrid_c); axis xy;
      %colormap('jet');
      title(sprintf('Prob. of class %s', c)); 
      colorbar
    end
    
    
end


function [X1, X2, yhat, phat] = gridPredict(range, resolution, predictFcn)
       X1range = linspace(range(1), range(2), resolution);
       X2range = linspace(range(3), range(4), resolution);
       [X1, X2] = meshgrid(X1range, X2range);
       [yhat, phat] = predictFcn([X1(:), X2(:)]);
       yhat = canonizeLabels(yhat);
end    
