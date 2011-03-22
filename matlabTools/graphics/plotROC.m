function h = plotROC(falseAlarmRate, detectionRate, col, EER, tprAtThresh, fprAtThresh)
% Plot (convex hull of a) receiver operating curve


% This file is from pmtk3.googlecode.com


k = convhull([colvec(falseAlarmRate); 1], [colvec(detectionRate); 0]);
%k = 1:numel(falseAlarmRate);
k = sort(k,'ascend');
if(k(end) > length(falseAlarmRate))
  k(end) = [];
end
h = plot(falseAlarmRate(k), detectionRate(k),  'color', col, 'LineWidth',2);
axis([0 1 0 1])
axis('square')

hold on
plot([0 1],[0 1],'k'); % 45deg up to upper right 
plot([0 1],[1 0],'k') % 45deg down to lower left
    
if nargin >= 4
  plot(EER, 1-EER, 'o', 'markersize', 12, 'linewidth', 2, 'color', col);
end
if nargin >= 5
  plot(fprAtThresh, tprAtThresh, 'x', 'markersize', 12, 'linewidth', 2, 'color', col);
end


end
