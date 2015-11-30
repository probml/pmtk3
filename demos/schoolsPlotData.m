
% see pmtk3/R/schools.R

y = [28,8,-3,7,-1,1,18,12];
sigma = [15,10,16,11,9,11,10,18];

%y(end+1) = mean(y)
%precision = 1./(sigma.^2);
%sigma(end+1) = sqrt(1/mean(precision))

figure; hold on;
for i=1:numel(y)
    h = line([y(i)-sigma(i), y(i)+sigma(i)], [i i]);
    h=plot(y(i),i,'k*');
end
set(gca,'ylim',[0 numel(y)+1]);
title('8 schools data (mean +- 1 std)')
printPmtkFigure('schoolsData');
