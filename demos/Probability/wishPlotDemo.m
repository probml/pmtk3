%% Wishart Distribution plots
%
%%
function wishPlotDemo()

setSeed(0);
nus = [2 5 10];
S   = [4 3; 3 4];
for j=1:length(nus)
    nu = nus(j);
    figure();
    WImodel.Sigma = S;
    WImodel.dof   = nu;
    for i=1:9
        subplot(3, 3, i)
        gaussPlot2d([0 0], wishartSample(WImodel));
        axis equal
    end
    suptitle(sprintf('Wishart(dof=%d, S = %s)', nu, mat2str(S)))
    printPmtkFigure(sprintf('wishplotS43nu%d', nu));
end
placeFigures();
end