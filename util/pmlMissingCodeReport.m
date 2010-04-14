function [missing, pg] = pmlMissingCodeReport(bookSource, includeCodeSol)
% Generate an html report of all of the code referenced in pml that
% cannot be found in PMTK. 
%% Input
%
% bookSource      - path to the PML latex source containing e.g. pml.tex
%                  (default = C:\kmurphy\local\PML\Text)
%
% includeCodeSol  - if true (default) the codeSol directory is also
%                   searched. 
%% Output
%
% missing         - a cell array of the missing m-files not found in PML
% pg              - hard cover page or pages where the code is referenced. 
%
%  *** Also displays an html table ***
%%

SetDefaultValue(1, 'bookSource', 'C:\kmurphy\local\PML\Text');
SetDefaultValue(2, 'includeCodeSol', true); 

if includeCodeSol
   codeSolDir = fullfile(bookSource, '..', 'CodeSol');
   codeSolFiles = mfiles(codeSolDir, 'removeExt', true);
else
    codeSolFiles = {};
end
[pmlCode, pg] = pmlCodeRefs(fullfile(bookSource, 'code.ind'));

missing = pmlCode;
[missing, idx] = setdiff(missing, codeSolFiles); 
pg = pg(idx); 
builtinMatlab = isbuiltin(missing); 
missing = missing(~builtinMatlab); 
pg = pg(~builtinMatlab); 
found = cellfun(@(c)exist(c, 'file'), missing); 
missing = missing(~found); 
pg = pg(~found); 
t = sprintf('Missing Files (%d)', numel(missing));
colNames = {'file name' 'page (s)'};
htmlTable('data', [missing, cellfuncell(@mat2str, pg)], 'title', t, 'dataAlign', 'left', 'colNames', colNames);



end



