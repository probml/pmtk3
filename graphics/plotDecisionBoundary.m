function plotDecisionBoundary(X, Y, predictFcn)
% Plot data and the classification boundaries induced by the specified 
% predictFcn. 
%
% X          - an n-by-2 data matrix
% Y          - an n-by-1 matrix of class labels
% predictFcn - a handle to a function of the form yhat = predictFcn(Xtest)
%
% Maximum 14 classes - although this is easy to change
%
% Examples
% plotDecisionBoundary(X, y, @(Xtest)logregPredict(model, Xtest));
% predictFcn = @(Xtest) logregPredict(model, rbfKernel(Xtest, X, rbfScale)); 
% plotDecisionBoundary(X, y, predictFcn);

    resolution = 200;   % set higher for smoother contours, lower for speed/mem
    nclasses = numel(unique(Y));
    range = dataWindow(X);
    X1range = linspace(range(1), range(2), resolution);
    X2range = linspace(range(3), range(4), resolution);
    [X1grid, X2grid] = meshgrid(X1range, X2range);
    [nrows, ncols] = size(X1grid);
    yhat = predictFcn([X1grid(:), X2grid(:)]);
    Y = canonizeLabels(Y);
    colors = 'rgbcymkrgbcymk'; symbols = '+ovd*.xs^d><ph';
    figure; hold on;
    for c=1:nclasses
        if isOctave()
            contour(X1grid, X2grid, reshape(yhat, nrows, ncols), 1:nclasses, 'LineWidth', 2);
        else
            contourShade(X1grid, X2grid, reshape(yhat, nrows, ncols), 1:nclasses, 'LineWidth', 2, 'FaceAlpha', 0.1);
        end
        plot(X(Y==c, 1), X(Y==c, 2), [colors(c), symbols(c)], 'LineWidth', 2, 'MarkerSize', 8);        
    end
    box on;
    set(gca, 'LineWidth', 2)
    axis(range);
end