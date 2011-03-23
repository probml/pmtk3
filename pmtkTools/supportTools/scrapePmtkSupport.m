function packages = scrapePmtkSupport(folder, exclude)
%% Scrape pmtkSupport.googleCode.com to get the names of all the support packages there

% This file is from pmtk3.googlecode.com

if nargin < 1, folder= []; end
if nargin < 2,  exclude = strtrim(tokenize(getConfigValue('PMTKmetaDirs'), ',')'); end


url = 'http://pmtksupport.googlecode.com/svn/trunk/';
if ~isempty(folder)
  url = sprintf('%s%s', url, folder)
end
raw = tokenize(urlread(url), '\n');
packages = filterCell(raw, @(c)startswith(strtrim(c), '<li>'));
packages(1) = []; % remove '..'
start = '<li><a href="';
packages = cellfuncell(@(c)c(numel(start)+1:end), packages); 
%packages = cellfuncell(@(c)strtok(c, '/'), packages);
packages = cellfuncell(@(c)strtok(c, '"'), packages);
packages = filterCell(packages, @(c)~isSubstring('>', c));
for i=1:numel(packages)
  if packages{i}(end)=='/', packages{i}(end)=[]; end % remove trailing /
   if startswith(packages{i}, '="')
       packages{i} = strtrim(packages{i}(3:end)); 
   end
end
packages = setdiff(packages, exclude)'; 
end
