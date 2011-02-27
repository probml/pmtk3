function [table, M] = parsePMLtypoFile(fname)
% Parse the PML typos file and generate an html table 
% listing the unique e-mail addresses and the number of each type of error
% found.
%
%  **** Download the file as a csv ****
%
%% Example
% parsePMLtypoFile('C:\users\matt\Desktop\typos.csv');

% This file is from pmtk3.googlecode.com


%% Setup
text = getText(fname);
text(1) = []; % header
emails = {};
types  = {};
%% Parse
for i=1:numel(text)
    line = text{i};
    if isempty(line)
        continue
    end
    toks = tokenize(text{i}, ',');
    if numel(toks) < 5
        continue
    end
    [date, email, pg, ln, type] = toks{:};
    if ~isSubstring('@', email)
        continue
    end
    if ~ismember(type, {'Math', 'Typo', 'Style'})
        continue
    end
    emails = [emails; email]; %#ok
    types  = [types; type];   %#ok
end
%% Consolidate
M = struct();
for i=1:numel(emails)
    e = emails{i};
    id = genvarname(e);
    if ~isfield(M, id)
        M.(id) = struct();
        M.(id).email = e;
        M.(id).Math  = 0;
        M.(id).Typo  = 0;
        M.(id).Style = 0;
    end
    M.(id).(types{i}) = M.(id).(types{i}) + 1;
end
%% Format
ids = fieldnames(M);
table = cell(numel(ids), 4);
for i=1:numel(ids)
    table{i, 1} = M.(ids{i}).email;
    table{i, 2} = M.(ids{i}).Math;
    table{i, 3} = M.(ids{i}).Typo;
    table{i, 4} = M.(ids{i}).Style;
end
perm = sortidx(sum(cell2mat(table(:,2:end)), 2), 'descend');
table = table(perm, :);
%% Display
colNames = {'Email', 'Math', 'Typo', 'Style'};
htmlTable('data', table, 'colNames', colNames);
end
