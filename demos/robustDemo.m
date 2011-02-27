%% Illustrate the robustness of the student and laplace distributions compared to the Gaussian.
%
%%

% This file is from pmtk3.googlecode.com

function robustDemo()

n = 30;
setSeed(8);
data = randn(n,1);
outliers = [8 ; 8.75 ; 9.5];
nn = length(outliers);
nbins = 7;

figure;
plotHist(data,nbins,n);
plotPDFs(data);
printPmtkFigure('robustDemoNoOutliers')
%%
figure;
plotHist(data,nbins,n+nn);
plotHist(outliers,nn,n+nn);
plotPDFs([data ; outliers]);
printPmtkFigure('robustDemoOutliers')

%% Bucket the data into nbins, divide the size of each bin by norm and plot
%% the normalized histogram. 
function plotHist(data,nbins,norm)
    hold on;
    [counts, locations] = hist(data,nbins);
    sCounts = counts ./ norm;
    bar(locations,sCounts);
end
%% 
function plotPDFs(data)
    Xbar = mean(data);
    sigma = std(data);
    gauss = @(X) gaussProb(X, Xbar, sigma.^2);
    model = studentFit(data);
    sT = @(X)exp(studentLogprob(model, X));
    model = laplaceFit(data);
    lap = @(X)exp(laplaceLogprob(model, X));   
    hold on;
    x = (-5:0.01:10)';
    h(1) = plot(x,gauss(x),'k:','LineWidth',3);
    h(2) = plot(x,sT(x),'r-','LineWidth',3);
    h(3) = plot(x,lap(x),'b--','LineWidth',3);
    axis([-5,10,0,0.5]);
    set(gca,'YTick',0:0.1:0.5);
    legendStr = {'gaussian', 'student T', 'laplace'};
    if isOctave(),
        legend(legendStr{:})
    else
        legend(h, legendStr{:})
    end
end


end
