load('yeastData310.mat') % 'X', 'genes', 'times');

doPrint = 0;
folder = 'C:\kmurphy\PML\Figures';


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
if doPrint
  fname = sprintf('%s/clusterYeastHier16.eps', folder)
  print(gcf, '-depsc', fname)
end

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
if doPrint
  fname = sprintf('%s/clusterYeastKmeans16.eps', folder)
  print(gcf, '-depsc', fname)
end


figure(3);clf
for c = 1:16
    subplot(4,4,c);
    plot(times,ctrs(c,:)');
    axis tight
    axis off    % turn off the axis
end
suptitle('K-Means centroids')
if doPrint
  fname = sprintf('%s/clusterYeastKmeansCentroids16.eps', folder)
  print(gcf, '-depsc', fname)
end


figure(4);clf;imagesc(X);colormap(redgreencmap)
xlabel('time')
set(gca,'xticklabel',times)
ylabel('genes')
title('yeast data (filtered)')
colorbar
if doPrint
  fname = sprintf('%s/clusterYeast310.eps', folder)
  print(gcf, '-depsc', fname)
end


figure(5);clf
clustergram(X(:,2:end),'RowLabels',genes, 'ColumnLabels',times(2:end))
title('hierarchical clustering')
if doPrint
  fname = sprintf('%s/clusterYeastRowPerm.eps', folder)
  print(gcf, '-depsc', fname)
end


figure(6); clf
dendrogram(linkage(corrDist, 'average'));
title('average link')
set(gca,'xticklabel','')
if doPrint
  fname = sprintf('%s/clusterYeastAvgLink.eps', folder)
  print(gcf, '-depsc', fname)
end

figure(7); clf
dendrogram(linkage(corrDist, 'complete'))
title('complete link')
set(gca,'xticklabel','')
if doPrint
  fname = sprintf('%s/clusterYeastCompleteLink.eps', folder)
  print(gcf, '-depsc', fname)
end

figure(8); clf
dendrogram(linkage(corrDist, 'single'))
title('single link')
set(gca,'xticklabel','')
if doPrint
  fname = sprintf('%s/clusterYeastSingleLink.eps', folder)
  print(gcf, '-depsc', fname)
end
