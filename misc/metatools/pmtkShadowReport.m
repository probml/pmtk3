function R = pmtkShadowReport()
%% Generate an hmtl report of the shadowd files in PMTK
files     = filelist(pmtk3Root(), '*.m', true);
main      = {};
shadows   = {};
identical = {};
fonly = @(f)argout(2, @fileparts, f);
files = cellfuncell(fonly, files); 

for i=1:numel(files)
    f = files{i};
    if strcmpi(f, 'Contents')
        continue;
    end
    w = which(f, '-all');
    w = filterCell(w, @(c)endswith(c, '.m') ...
        && ~issubstring([filesep, 'private', filesep], c)...
        && ~issubstring('@', c));
    if numel(w) < 2
        continue
    end
    identical = insertEnd(cellfuncell(@(wi)isident(w{1}, wi), w(2:end)), identical);
    w         = cellfuncell(@removePrefix, w);
    main      = insertEnd(w{1}, main);
    shadows   = insertEnd(w(2:end), shadows);
end
 
pmtkRed  = '#990000';
R = [main', shadows', identical'];
htmlTable('data', R, 'colNames', {'Main File', 'Shadows', 'Identical?'}, ...
    'colNameColors', {pmtkRed, pmtkRed, pmtkRed}, ...
    'title', 'PMTK Shadowed Files', ...
    'dataAlign', 'left', 'caption', '(identical means identical ignoring comments and spaces)', ...
    'captionLoc', 'top'); 

end

function f = removePrefix(f)
% Remove file path prefixes for pmtk3 and matlabroot
if startswith(f, pmtk3Root())
    f = f(length(pmtk3Root())+1:end);
end
if startswith(f, matlabroot())
    f = ['(matlab) ', f(length(matlabroot())+1:end)];
end
end

function tf = isident(main, shadow)
% Return text 'true' if the files are identical, else 'false'
if ~exist(main, 'file') || ~exist(shadow, 'file')
    tf = 'unknown';
    return;
end
f1 = removeComments(getText(main));
f2 = removeComments(getText(shadow));
f1 = cellfuncell(@(c)strrep(c, ' ', ''), f1);
f2 = cellfuncell(@(c)strrep(c, ' ', ''), f2);
f1 = filterCell(f1, @(c)~isempty(c)); 
f2 = filterCell(f2, @(c)~isempty(c)); 
if isequal(f1, f2)
    tf = 'true';
else
    if strcmp(f1{end}, 'end') && isequal(f1(1:end-1), f2)
        tf = 'true';
    elseif strcmp(f2{end}, 'end') && isequal(f1, f2(1:end-1))
        tf = 'true';
    else
        tf = 'false';
    end
end

end

