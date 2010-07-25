function modDate = pmlGetLastModDate()
%% Get the file mod date for pml.pdf if it exists: pml.tex otherwise
%
%%
bookSource = getConfigValue('PMTKpmlBookSource');
pmlFile = fullfile(bookSource, 'pml.tex'); 
pmlPdfFile = fullfile(bookSource, 'pml.tex'); 
if exist(pmlPdfFile, 'file'); 
    modDate = getFileModificationDate(pmlPdfFile); 
else
    modDate = getFileModificationDate(pmlFile); 
end

end