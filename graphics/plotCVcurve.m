function [h, he, hline] = plotCVcurve(lambdas, cvMeanErrors, cvStdErrors, lambdaBest, useLogScale)
% Plot a cross validation curve with error bars.
% This is just a pretty version of the built in errorbars function. 
%
% lambdas      - the parameter values, e.g. regularization coeffs. 
% cvMeanErrors - the expected errors
% cvStdErrors  - the standard errors
% lambdaBest   - value chosen by cv. 
% useLogScale  - if true, use log scale for x-axis

if nargin < 5, useLogScale = false;  end
if useLogScale
    axes('XScale', 'log');
    hold on    
end
colors = pmtkColors(); 


hold on;
he = errorbar(lambdas, cvMeanErrors, cvStdErrors, 'Color', colors{1});
h = plot(lambdas, cvMeanErrors, '-o', 'Color', colors{1}, ...
    'LineWidth', 2,'MarkerFaceColor', colors{2}, 'MarkerEdgeColor', 'k', 'MarkerSize', 8);
xlabel('parameter value'); 
ylabel('CV error'); 
box on; 
axis tight;
hline = verticalLine(lambdaBest, 'Color', colors{3}, 'LineWidth', 2, 'LineStyle', '--');
uistack(hline, 'bottom')
set(gca, 'XTick', sort([lambdaBest, get(gca, 'XTick')]));
    
    
    

    
    
end