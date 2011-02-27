function dataSets = scrapePmtkData()
%% Scrape pmtkData.googleCode.com to get the names of all the data sets there

% This file is from pmtk3.googlecode.com

excludedDirs = tokenize(getConfigValue('PMTKmetaDirs'), ',')';

url = 'http://pmtkdata.googlecode.com/svn/trunk/';

raw = tokenize(urlread(url), '\n');
dataSets = filterCell(raw, @(c)startswith(c, '<li>'));
dataSets(1) = []; % remove '..'
start = '<li><a href="';
dataSets = cellfuncell(@(c)c(numel(start)+1:end), dataSets); 
dataSets = cellfuncell(@(c)strtok(c, '/'), dataSets);
dataSets = filterCell(dataSets, @(c)~isSubstring('.', c)); 
dataSets = setdiff(dataSets, excludedDirs)'; 
end
