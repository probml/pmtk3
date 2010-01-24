%% Linear Regression with Polynomial Expansion
[xtrain, ytrain, xtest, ytestNoisefree, ytest] = polyDataMake('sampling','thibaux');
degs = 1:2;
for i=1:length(degs)
    deg = degs(i);
    m = Linreg;
    m.transformer =  ChainTransformer({RescaleTransformer, PolyBasisTransformer(deg,false)});
    m = fit(m, DataTableXY(xtrain, ytrain));
    ypredTest = predict(m, xtest);
    figure;
    scatter(xtrain,ytrain,'b','filled');
    hold on;
    plot(xtest, ypredTest, 'k', 'linewidth', 3);
    hold off
    title(sprintf('degree %d', deg))
    %set(gca,'ylim',[-10 15]);
    set(gca,'xlim',[-1 21]);
end

