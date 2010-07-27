function generateModelsVsMethodsTables()
%% Make the models vs methods tables

pmtkRed = getConfigValue('PMTKred');
modelTags = {'PMTKlatentmodel', 'PMTKgmmodel', 'PMTKsupervisedmodel'};
R = pmtkTagReport(fullfile(pmtk3Root(), 'toolbox'));
exchar = '*'; 


for t = 1:numel(modelTags)
    
    
    
    files = R.tagmap.(modelTags{t});
    if isfield(R.tagmap, [modelTags{t}, exchar])
        exceptions = R.tagmap.([modelTags{t}, exchar]);
    else
        exceptions = {};
    end
    
    for f=1:numel(files)
        ndx     = R.filendx(files{f});
        tags    = R.tags(ndx); 
        tagtext = R.tagtext(ndx); 
        
    end
    
    
    
    
    
    
    
end




end