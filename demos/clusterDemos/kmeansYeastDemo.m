load('yeastData310.mat') % 'X', 'genes', 'times');



figure;imagesc(X);colormap(redgreencmap)
xlabel('time')
set(gca,'xticklabel',times)
ylabel('genes')
title('yeast microarray data')
colorbar
printPmtkFigure('yeastHeatMap'); 

%figure; plot(X'); set(gca,'xticklabel',times);
figure; plot(times,X,'o-');
xlabel('time')
set(gca,'xticklabel',times)
set(gca,'xtick',times)
ylabel('genes')
title('yeast microarray data', 'fontsize', 12)
set(gca,'xlim',[0 max(times)])
printPmtkFigure('yeastTimeSeries'); 


%[cidx, ctrs] = kmeans(X, 16, 'dist','corr', 'rep',5, 'disp','final');
[ctrs, cidx] = kmeansSimple(X, 16);
ctrs = ctrs';
figure;
for c = 1:16
    subplot(4,4,c);
    plot(times,X((cidx == c),:)');
    axis tight
end
suptitle('K-Means Clustering of Profiles');
printPmtkFigure('clusterYeastKmeans16')


figure;
for c = 1:16
    subplot(4,4,c);
    plot(times,ctrs(c,:)','-' ,'linewidth', 3);
    axis tight
    axis off    % turn off the axis
end
suptitle('K-Means centroids')
printPmtkFigure('clusterYeastKmeansCentroids16')



