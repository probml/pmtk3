function generateHelpPages()
%% Generate the help documentation listing files and one line desriptions.

dest = fullfile(pmtk3Root(), 'docs', 'helpPages'); 
%% Toolbox
d = dirs(fullfile(pmtk3Root(), 'toolbox')); 
for i=1:numel(d)
   generateHelpTable(fullfile(pmtk3Root(), 'toolbox', d{i}), ...
                     fullfile(dest, sprintf('%s.html', d{i})));
    
end
%% Util
generateHelpTable(fullfile(pmtk3Root(), 'misc', 'util'), fullfile(dest, 'util.html'));
%% Meta Tools
generateHelpTable(fullfile(pmtk3Root(), 'misc', 'metatools'), fullfile(dest, 'metatools.html'));

end