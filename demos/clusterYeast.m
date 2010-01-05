load('yeastData310.mat') % 'X', 'genes', 'times');

corrDist = pdist(X, 'corr');
clusterTree = linkage(corrDist, 'average');
clusters = cluster(clusterTree, 'maxclust', 16);
figure(1);clf
for c = 1:16
    subplot(4,4,c);
    plot(times,X((clusters == c),:)');
    axis tight
end
suptitle('Hierarchical Clustering of Profiles')
printPmtkFigure('clusterYeastHier16')

[cidx, ctrs] = kmeans(X, 16,... 
                      'dist','corr',...
                      'rep',5,...
                      'disp','final');
figure(2);clf
for c = 1:16
    subplot(4,4,c);
    plot(times,X((cidx == c),:)');
    axis tight
end
suptitle('K-Means Clustering of Profiles');
printPmtkFigure('clusterYeastKmeans16')


figure(3);clf
for c = 1:16
    subplot(4,4,c);
    plot(times,ctrs(c,:)');
    axis tight
    axis off    % turn off the axis
end
suptitle('K-Means centroids')
printPmtkFigure('clusterYeastKmeansCentroids16')


figure(4);clf;imagesc(X);colormap(redgreencmap)
xlabel('time')
set(gca,'xticklabel',times)
ylabel('genes')
title('yeast data (filtered)')
colorbar
printPmtkFigure('clusterYeast310')


figure(5);clf
clustergram(X(:,2:end),'RowLabels',genes, 'ColumnLabels',times(2:end))
title('hierarchical clustering')
printPmtkFigure('clusterYeastRowPerm')


figure(6); clf
dendrogram(linkage(corrDist, 'average'));
title('average link')
set(gca,'xticklabel','')
printPmtkFigure('clusterYeastAvgLink')

figure(7); clf
dendrogram(linkage(corrDist, 'complete'))
title('complete link')
set(gca,'xticklabel','')
printPmtkFigure('clusterYeastCompleteLink')

figure(8); clf
dendrogram(linkage(corrDist, 'single'))
title('single link')
set(gca,'xticklabel','')
printPmtkFigure('clusterYeastSingleLink')
