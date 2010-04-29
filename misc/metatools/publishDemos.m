function publishDemos(wikiFile)
% Publish all of the PMTK3 demos and create the wiki TOC page.

svnAutomatically = false;
shadowFunction({'pause', 'keyboard', 'input', 'placeFigures'});
cleaner = onCleanup(@removeShadows);
if nargin == 0
    wikiFile = 'C:\pmtk3wiki\Demos.wiki';
end
cd(fullfile(pmtk3Root(), 'demos'));
d = dirs();
dirEmpty = @(d)isempty(mfiles(d,'topOnly', true));

for i = 1:numel(d)
    if ~dirEmpty(d{i})
        publishFolder(d{i});
    end
end



googleRoot = 'http://pmtk3.googlecode.com/svn/trunk/docs/demos';
wikiText = cell(numel(d), 1);
for i=1:numel(d)
    wikiText{i} = sprintf(' * [%s/%s/index.html %s]',googleRoot, d{i}, d{i});
end

writeText(wikiText, wikiFile);
if svnAutomatically
    system(sprintf('svn ci %s -m "auto-updated by publishDemos"', wikiFile));
    docdir = fullfile(pmtk3Root(), 'docs', 'demos');
    system(sprintf('svn ci %s -m "auto-updated by publishDemos"', docdir));
end
end