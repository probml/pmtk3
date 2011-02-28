%% Hierarchical Clustering Demo
%PMTKneedsStatsToobox cluster, pdist, linkage
%PMTKneedsBioToolbox clustergram
%%

% This file is from pmtk3.googlecode.com

%requireStatsToolbox
%requireBioinfoToolbox
if ~bioinfoToolboxInstalled
    fprintf('cannot run %s without bioinformatics toolbox; skipping\n', mfilename());
    return;
end
loadData('yeastData310') % 'X', 'genes', 'times');

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
