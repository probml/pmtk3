function list = listAuthoredFiles(directory)
%% List all matlab files with PMTKauthor tags that are not part of packages.

excludedAuthors = tokenize(getConfigValue('PMTKauthors'), ',');

m = filelist(directory, '*.m', true); 
m = setdiff(m, listPackageFiles(directory)); 
authors = getTagText(m, 'PMTKauthor');
list = m(cellfun(@(c)~isempty(c) && ~ismember(c, excludedAuthors), authors));





end