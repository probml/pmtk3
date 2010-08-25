function generateModelLists()
%% Make the model list html pages
% This looks for PMTKdefn tags in model constructors.
%PMTKneedsMatlab
%%

outputDir = fullfile(pmtk3Root(), 'docs', 'modelLists'); 
[basic, supervised, latent, graphical] = classNameMappings();
defnTag = 'PMTKdefn';


titles = {
    'Basic Models'    
    'Supervised Models'
    'Latent Variable Models'
    'Graphical Models'
    };

outputFile = 'modelList.html';

%%
nbasic = numel(basic); 
basicData = cell(numel(basic), 2); 
basicData(:, 1) = basic;
for i=1:nbasic
   constructor = sprintf('%sCreate', basic{i});
   if exist(constructor, 'file')
      txt = getTagText(constructor,  defnTag); 
      if ~isempty(txt)
          imgName = sprintf('%sDefn', basic{i}); 
          basicData{i, 2} = texifyFormula(txt{1}, imgName, outputDir); 
      end
   end
end



end