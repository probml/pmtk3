function showImmediateToolboxDependencies(fname)
%% Display the immediate toolbox dependencies of a function

% This file is from pmtk3.googlecode.com

if nargin == 0;
    fname = currentlyOpenFile(true);
end

D = depfun(fname, '-toponly', '-quiet');
[TB, NTB] = partitionCell(D, ...
    @(c)~startswith(c, fullfile(matlabroot, 'toolbox', 'matlab')) && ...
    startswith(c, fullfile(matlabroot, 'toolbox')));

if isempty(TB)
    fprintf('NO IMMEDIATE TOOLBOX DEPENDENCIES\n');
else
    fprintf('**** TOOLBOX DEPENDENCIES **** \n');
    START = length(fullfile(matlabroot, 'toolbox'))+2;
    disp(cellfuncell(@(c)c(START:end), TB));
    fprintf('******************************\n');
end
end



