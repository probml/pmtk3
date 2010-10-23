function matlabToolsSynopses()
%% Generate the synopses listing files and one line desriptions for matlabTools
% PMTKneedsMatlab
%%

% This file is from matlabtools.googlecode.com

dest = fullfile(matlabToolsRoot(), 'docs', 'synopsis'); 
d = {'graph', 'graphics', 'metaTools', 'oop', 'stats', 'util'}; 
for i=1:numel(d)
   directory = fullfile(matlabToolsRoot(), d{i});
   outputFile = fullfile(dest, sprintf('%s.html', d{i}));
   generateSynopsisTable(directory, outputFile, matlabToolsRoot());
end
%%
end
