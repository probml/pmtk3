%% boxplot of the Michelson-Morley data
% Based on http://en.wikipedia.org/wiki/File:Michelsonmorley-boxplot.svg
% PMTKneedsStatsToolbox boxplot
%%

% This file is from pmtk3.googlecode.com

requireStatsToolbox
loadData('morley');
for notched = [false true]
%notched = true;

figure;
if(notched)
  boxplot(Speed, Expt, 'notch', 'on');
else
  boxplot(Speed, Expt);
end
line([0,6],[truth, truth], 'color', 'red', 'linewidth', 3)
text(2.5, truth-15, 'true speed', 'FontSize', 16);
ylabel('Speed of light (km/s minus 299,000)');
xlabel('Experiment No.');

if(notched)
  printPmtkFigure('morleyNotched');
else
  printPmtkFigure('morley');
end

end

