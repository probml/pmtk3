function generateToolboxHelpPages()
%% Generate the help documentation listing files and one line desriptions.

dest = fullfile(pmtk3Root(), 'docs', 'helpPages', 'toolbox'); 
d = dirs(fullfile(pmtk3Root(), 'toolbox')); 

for i=1:numel(d)
   outdir = fullfile(dest, d{i});
   if ~exist(outdir, 'file')
       mkdir(outdir);
   end
   generateHelpTable(fullfile(pmtk3Root(), 'toolbox', d{i}), ...
                     fullfile(outdir, sprintf('%s.html', d{i})));
    
end


end