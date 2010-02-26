function publishDemos()

wikiFile = 'C:\pmtk3wiki\Demos.wiki';

cd(fullfile(pmtk3Root(), 'demos'));
d = dirs(); 
for i = 1:numel(d)
    publishFolder(d{i}); 
end



googleRoot = 'http://pmtk3.googlecode.com/svn/trunk/docs/demos';
wikiText = cell(numel(d), 1); 
for i=1:numel(d)
    wikiText{i} = sprintf(' * [%s/%s/index.html %s]',googleRoot, d{i}, d{i});
end

writeText(wikiText, wikiFile); 