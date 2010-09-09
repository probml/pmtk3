function packages = scrapePmtkSupport()
%% Scrape pmtkSupport.googleCode.com to get the names of all the support packages there

% This file is from pmtk3.googlecode.com

excludedDirs = strtrim(tokenize(getConfigValue('PMTKmetaDirs'), ',')');

url = 'http://pmtksupport.googlecode.com/svn/trunk/';

raw = tokenize(urlread(url), '\n');
packages = filterCell(raw, @(c)startswith(strtrim(c), '<li>'));
packages(1) = []; % remove '..'
start = '<li><a href="';
packages = cellfuncell(@(c)c(numel(start)+1:end), packages); 
packages = cellfuncell(@(c)strtok(c, '/'), packages);
packages = filterCell(packages, @(c)~isSubstring('>', c));
for i=1:numel(packages)
   if startswith(packages{i}, '="')
       packages{i} = strtrim(packages{i}(3:end)); 
   end
end
packages = setdiff(packages, excludedDirs)'; 
end
