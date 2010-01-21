function plotDecisionBoundary(X, Y, predictFcn)
% Plot data and the classification boundaries induced by the specified 
% predictFcn. 
%
% predictFcn must be of the form [yhat, prob] = predictFcn(X)
%
%
%
    
    nclasses = numel(unique(Y));
    X1range = linspace(min(X(:, 1)), max(X(:, 1)), 50);
    X2range = linspace(min(X(:, 2)), max(X(:, 2)), 50);
    [X1grid, X2grid] = meshgrid(X1range, X2range);
    [nrows,ncols] = size(X1grid);
    [yhat, prob] = predictFcn([X1grid(:), X2grid(:)]);
    if size(prob, 2) == 1
        prob = [prob, 1-prob];
    end
    Y = canonizeLabels(Y);
    [styles, colors, symbols] =  plotColors();
    figure; hold on;
    for c=1:nclasses
        plot(X(Y==c, 1), X(Y==c, 2), [colors(c), symbols(c)], 'LineWidth', 2, 'MarkerSize', 7);
        binaryProb = normalize([prob(:, c), max(prob(:, setdiff(1:nclasses, c)), [], 2)], 2);
        probGrid = reshape(binaryProb(:, 1), nrows, ncols);
        contour(X1grid, X2grid, probGrid, 'LineColor', 'k', 'LevelStep', 0.5, 'LineWidth',2.5);  
    end
    box on;
    axis tight
end