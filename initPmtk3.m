% first ensure you are in the root directory of pmtk3
disp('initializing pmtk3')
addpath(genpathPMTK(pwd))
format compact

% determine which toolboxes are on the matlab path.
% (It is slow to repeatedfly determine this inside a function.)
global BIOTOOLBOXINSTALLED  STATSTOOLBOXINSTALLED
BIOTOOLBOXINSTALLED = bioToolboxInstalled(); 
STATSTOOLBOXINSTALLED = statsToolboxInstalled();

% for windows users only
if ispc()
folder = fullfile(pmtk3Root(), 'toolbox', 'Kernel_methods_for_supervised_learning');
dirs = {'svmLightWindows', 'liblinear-1.51\windows', 'libsvm-mat-2.9.1'};
for i=1:length(dirs)
  addtosystempath(fullfile(folder, dirs{i}))
end
end