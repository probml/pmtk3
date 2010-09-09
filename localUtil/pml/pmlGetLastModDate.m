function modDate = pmlGetLastModDate()
%% Get the file mod date for pml.pdf if it exists: pml.tex otherwise
%
%%

% This file is from pmtk3.googlecode.com

bookSource = getConfigValue('PMTKpmlBookSource');
pmlFile = fullfile(bookSource, 'pml.tex'); 
pmlPdfFile = fullfile(bookSource, 'pml.pdf'); 
if exist(pmlPdfFile, 'file'); 
    modDate = getFileModificationDate(pmlPdfFile); 
else
    modDate = getFileModificationDate(pmlFile); 
end

end
