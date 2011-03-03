function libdaiParseAliasesConf()
%% Parse the libdai aliases.conf file and save the results in a struct

% This file is from pmtk3.googlecode.com


%fpath = fullfile(getConfigValue('PMTKlibdaiPath'), 'tests', 'aliases.conf')
fpath = 'C:\boost\libDAI-0.2.5\tests\aliases.conf'; 

raw = getText(fpath); 
raw = removeEmpty(raw);
raw = filterCell(raw, @(c)~startswith(strtrim(c), '#')); 
raw = strtrim(raw); 
raw = cellfuncell(@(c)strtrim(tokenize(c, ':')), raw);
S = struct; 
for i=1:numel(raw)
    alias = upper(raw{i}{1});
    meth  = strtok(raw{i}(2), '[');
    opts  = ['[',textBetween(raw{i}{2}, '[', ']') ,']'];
    
    S.(alias) = {meth{1}, opts};
end
save(fullfile(fileparts(which(mfilename)), 'libdaiDefaults'), 'S'); 


end
