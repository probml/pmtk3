%% Agglomerative Clustering Demo
%PMTKneedsStatsToolbox dendrogram, cophenet, linkage
% Based on http://www.mathworks.com/access/helpdesk/help/toolbox/stats/index.html
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
clear all

if 0 % Alpaydin data
    X = [1 3;
        1 4;
        5 2;
        5 1;
        2 2;
        7 2];
end


X = [1 2;2.5 4.5;2 2;4 1.5;4 2.5]

figure;
axis on
grid on
N = size(X,1);
for i=1:N
    hold on
    h=text(X(i,1)-0.1, X(i,2), sprintf('%d', i));
    set(h,'fontsize',20,'color','r')
end
axis([0 8 0 5])
printPmtkFigure('agglomDemoData')

Y= pdist(X); % Euclidean distance
Z = linkage(Y); % single link
h=dendrogram(Z);
set(gca,'fontsize',20)
printPmtkFigure('agglomDemoDendrogram')


Y = pdist(X,'cityblock');
Z = linkage(Y,'average');
c = cophenet(Z,Y);
