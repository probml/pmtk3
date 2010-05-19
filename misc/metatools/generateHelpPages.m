function generateHelpPages()
%% Generate the help documentation listing files and one line desriptions.

wikiFile = 'C:\pmtk3wiki\synopsisPages.wiki';
dest = fullfile(pmtk3Root(), 'docs', 'synopsis'); 
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
googleRoot = 'http://pmtk3.googlecode.com/svn/trunk/docs/synopsis';
wikiText = cell(numel(d), 1);
for i=1:numel(d)
    if exist(fullfile(dest, [d{i}, '.html']), 'file')
        wikiText{i} = sprintf(' * [%s/%s.html %s]',googleRoot, d{i}, d{i});
    end
end
wikiText = filterCell(wikiText, @(c)~isempty(c));
wikiText =  [{'== Toolboxes =='
            ''
            ''
             };
            wikiText
            {
            ''
            ''
            '== Other =='
            ''
            ''
            sprintf(' * [%s/%s.html %s]', googleRoot, 'util', 'util');
            sprintf(' * [%s/%s.html %s]', googleRoot, 'metatools', 'metatools');
            }];
            
writeText(wikiText, wikiFile); 
end