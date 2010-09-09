%% Prostate pscatter demo
%
%%

% This file is from pmtk3.googlecode.com

loadData('prostate');
figure;
pscatter([y X], 'vnames', {names{end}, names{1:end-1}})
svi = unique(X(:,5))
gleason = unique(X(:,7))
printPmtkFigure('prostateScatter')
