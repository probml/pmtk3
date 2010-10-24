function h = plotDecisionBoundary(X, Y, predictFcn, varargin)
% Plot data and the classification boundaries induced by the specified 
% predictFcn. 
%
% X          - an n-by-2 data matrix
% Y          - an n-by-1 matrix of class labels
% predictFcn - a handle to a function of the form yhat = predictFcn(Xtest)
% stipple    - [true] If true, use stippling, else use pastel translucent
%              shading
%
% Maximum 14 classes - although this is easy to change
%
% Examples
% plotDecisionBoundary(X, y, @(Xtest)logregPredict(model, Xtest));
% predictFcn = @(Xtest) logregPredict(model, kernelRbfSigma(Xtest, X, rbfScale)); 
% plotDecisionBoundary(X, y, predictFcn);
%%

% This file is from pmtk3.googlecode.com

    [stipple     , colors   , symbols,   markersize     , ...
     markerLineWidth, contourProps, newFigure, resolution ] = ...
        process_options( varargin                       , ...
        'stipple'      , true                           , ...
        'colors'       , pmtkColors()                   , ...
        'symbols'      , '+ovd*.xs^d><ph'               , ...
        'markerSize'   , 8                              , ...
        'markerLineWidth', 2                            , ...
        'contourProps' , {'LineWidth', 2, 'Color', 'k'} , ...
        'newFigure'    , true                           , ...
        'resolution'   , 300);
    
    nclasses = nunique(Y);
    range = dataWindow(X);
    [X1grid, X2grid, yhat] = gridPredict(range, resolution, predictFcn);
    [X1sparse, X2sparse, yhatSparse] = gridPredict(range, resolution / 2.5, predictFcn);
    [nrows, ncols] = size(X1grid);
    Y = canonizeLabels(Y);
    if newFigure, figure; hold on; end
    h = zeros(nclasses, 1);
    for c=1:nclasses
        if ~stipple && ~isOctave
            contourShade(X1grid, X2grid, reshape(yhat, nrows, ncols), 1:nclasses, 'LineWidth', 2, 'FaceAlpha', 0.1);
        else
            X1sparse = X1sparse(:); X2sparse = X2sparse(:);
            plot(X1sparse(yhatSparse==c), X2sparse(yhatSparse==c), '.', 'Color', colors{c}, 'MarkerSize', 0.05);
            contour(X1grid, X2grid, reshape(yhat, nrows, ncols), 1:nclasses, contourProps{:});
        end
        h(c) = plot(X(Y==c, 1), X(Y==c, 2), symbols(c), 'Color', colors{c}, ...
          'LineWidth', markerLineWidth, 'MarkerSize', markersize);        
    end
    axis(range);
    box on;
    axis tight
end


function [X1, X2, yhat] = gridPredict(range, resolution, predictFcn)
       X1range = linspace(range(1), range(2), resolution);
       X2range = linspace(range(3), range(4), resolution);
       [X1, X2] = meshgrid(X1range, X2range);
       yhat = canonizeLabels(predictFcn([X1(:), X2(:)]));
end    
