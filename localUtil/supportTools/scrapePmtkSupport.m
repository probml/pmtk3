function dataSets = scrapePmtkSupport()
%% Scrape pmtkSupport.googleCode.com to get the names of all the support packages there
excludedDirs = tokenize(getConfigValue('PMTKmetaDirs'), ',')';

url = 'http://pmtksupport.googlecode.com/svn/trunk/';

raw = tokenize(urlread(url), '\n');
dataSets = filterCell(raw, @(c)startswith(c, '<li>'));
dataSets(1) = []; % remove '..'
start = '<li><a href="';
dataSets = cellfuncell(@(c)c(numel(start)+1:end), dataSets); 
dataSets = cellfuncell(@(c)strtok(c, '/'), dataSets);
dataSets = filterCell(dataSets, @(c)~isSubstring('.', c)); 
dataSets = setdiff(dataSets, excludedDirs)'; 
end