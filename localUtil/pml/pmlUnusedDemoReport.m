function extra = pmlUnusedDemoReport(bookSource)
% Generate an hmtl report of the PMTK demos NOT currently used by pml.
%
%% Input
%
% bookSource      - path to the PML latex source containing e.g. pml.tex
%                  (default = C:\kmurphy\dropbox\PML\Text)
%% Output
%
%% extra          - a cell array of the demo files not referenced in PML
%
%  *** Also displays an html table ***
%%

% This file is from pmtk3.googlecode.com

SetDefaultValue(1, 'bookSource', getConfigValue('PMTKpmlBookSource'));
pmlCode = pmlCodeRefs(fullfile(bookSource, 'code.ind'));
pmtkDemos = mfiles(fullfile(pmtk3Root(), 'bookDemos'), 'removeExt', true);
extra = setdiff(pmtkDemos, pmlCode);
t = sprintf('Unused Demos (%d)', numel(extra));
htmlTable('data', extra, 'dataAlign', 'left', 'title', t);


end
