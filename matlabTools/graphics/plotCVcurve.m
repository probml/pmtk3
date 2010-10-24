function [h, he, vline, hline] = plotCVcurve(lambdas, cvMeanErrors, cvStdErrors, lambdaBest, useLogScale, hline)
% Plot a cross validation curve with error bars.
% This is just a pretty version of the built in errorbars function. 
%
% lambdas      - the parameter values, e.g. regularization coeffs. 
% cvMeanErrors - the expected errors
% cvStdErrors  - the standard errors
% lambdaBest   - value chosen by cv. 
% useLogScale  - if true, use log scale for x-axis

% This file is from pmtk3.googlecode.com


warning('off', 'MATLAB:Axes:NegativeDataInLogAxis');
if nargin < 5, useLogScale = false;  end
if useLogScale
    axes('XScale', 'log');
    hold on    
end
colors = pmtkColors(); 

if isOctave()
    he = errorbar(lambdas, cvMeanErrors, cvStdErrors); 
else
    hold on;
    he = errorbar(lambdas, cvMeanErrors, cvStdErrors, 'Color', colors{1});
    h = plot(lambdas, cvMeanErrors, '-o', ...
        'Color',            colors{1}, ...
        'LineWidth',        2,         ...
        'MarkerFaceColor',  colors{2}, ...
        'MarkerEdgeColor',  'k',       ...
        'MarkerSize',       8          );


    xlabel('parameter value'); 
    ylabel('CV error'); 
    box on; 
    if nargin == 6
       hline = horizontalLine(hline, 'LineStyle', '--', 'Color', colors{4}, 'LineWidth', 2);  
    else
        hline = [];
    end
    axis tight;
    ylimits = get(gca, 'ylim'); 
    ylimits(1) = ylimits(1) - 0.1*diff(ylimits); 
    ylimits(2) = ylimits(2) + 0.1*diff(ylimits); 
    set(gca, 'ylim', ylimits); 
    vline = verticalLine(lambdaBest, 'Color', colors{3},...
        'LineWidth', 2, 'LineStyle', '--');
    uistack(vline, 'bottom')
    if ~isempty(hline)
       uistack(hline, 'bottom');  
    end
    %legend(hline, sprintf('%.2f', lambdaBest));
    title(sprintf('selected value: %.2f', lambdaBest)); 
end


end
