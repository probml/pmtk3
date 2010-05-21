function R = pmtkShadowReport()
%% Generate an hmtl report of the shadowd files in PMTK
files     = filelist(pmtk3Root(), '*.m', true);
main      = {};
shadows   = {};
identical = {};
fonly = @(f)argout(2, @fileparts, f);

for i=1:numel(files)
    f = fonly(files{i});
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
    'dataAlign', 'left')

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
if isequal(getText(main), getText(shadow))
    tf = 'true';
else
    tf = 'false';
end
end