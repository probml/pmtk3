function I = pmtkTagReport(root)
%% Gather info on all of the tags in the PMTK3 system.
% I is a struct with the following fields:
%   files............a list of all of the PMTK3 files with at least one tag
%   tags.............tags{i} are the tags for files{i}
%   tagtext..........tagtext{i}{j} is the remaining text after tag{j} in 
%                    files{i}.
%   codelen..........codelen(i) is the number of non-blank lines in 
%                    files{i}. If files{i} is a Contents.m files, then 
%                    codelen is the code length of all of the files in the 
%                    containing directory structure.
%   fulltext.........fulltext{i}{j} is the jth line of files{i} (includes 
%                    blank lines)
%   authors..........authors{i}{j} is the jth author of files{i}
%   nfiles...........the number of files in the report.
%   tagmap...........tagmap.(tag) returns a cell array of all of the files 
%                    with this tag.
%   filendx..........filendx(filename) returns the index of the filename in
%                    files.
%   hastag...........hastag(f, tag) = true iff file f has the tag.
%   authorlist.......a list of all of the authors found
%   contribution.....contribution(j) is the total contribuion in lines of
%                    code by authorlist{j} - sorted in descending order
%   isauthor.........isauthor(i, j) = true iff authorlist(j) is an author
%                    of files{i}.
%   iscontents.......iscontents(i) = true iff files{i} is a Contents.m file
%   isbinary.........isbinary(i) = true iff files{i} is a Contents.m files
%                    and there are executable, *.exe, or *.bin files in the 
%                    containing directory structure. 
%%
%

% This file is from pmtk3.googlecode.com

if nargin < 1, 
    searchDirs = tokenize(getConfigValue('PMTKcodeDirs'), ','); 
    root = cellfuncell(@(d)fullfile(pmtk3Root(), d), searchDirs); 
end
I = tagReport(root); 
end
