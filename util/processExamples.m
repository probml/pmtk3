function [text, excluded] = processExamples(includeTags, excludeTags, pauseTime, doformat, subFolder)
% Examine all of the PMTK demos and return a cell array of formatted names
% corresponding to examples consistent with the specified include and
% exclude tags. The semantics of includeTags and excludeTags are as
% follows:
%
% excludeTags have no effect on what examples make it onto the list,
% however, examples that do make in on the list and have at least one of
% the tags in excludeTags, are commented out with a comment derived from the
% matched tags.
%
% If includeTags is empty or unspecified, all examples are included on the
% list, otherwise an example is included iff it has at least one of the
% tags specified in includeTags.
%
% INPUT:
%
% includeTags and excludeTags are cell arrays of string tags with each tag
% beginning with the # character.
%
% pauseTime specifies the time to wait in seconds between the execution of
% consecutive examples (default = 0).
%
% if doformat is true, (default), the text is formatted for writing to a
% file, (e.g. runDemos.m). If false, only the names of the mfiles
% that have a tag in includeTags and have no tags in excludeTags are
% included, with no formatting.
%
% OUTPUT:
%
% text is a formatted cell array, ready to be written to a file using
% say writeText(text,fname).
%
% EXAMPLES:
%
% text = processExamples({},{'PMTKinprogress','PMTKslow','PMTKbroken'})  % used to make testPMTK
% text = processExamples({},{'PMTKinprogress','PMTKbroken'})                     % used to make runDemos

if nargin < 1, includeTags = {}; end
if nargin < 2, excludeTags = {}; end
if nargin < 3, pauseTime = 0; end
if nargin < 4, doformat = true; end
cd(fullfile(pmtk3Root(),'demos'));                                     % change directory to /pmtk/examples/
if nargin == 5 && ~isempty(subFolder)
    cd(subFolder)
end
[info,mfiles] = mfilelist();                                           % grab the names of all the mfiles there - including subdirectories if any
tags = cellfuncell(@tagfinder,mfiles)';                                % get all of the tags in each of these mfiles
if isempty(includeTags)
    include = true(numel(mfiles),1);                                    % if no includeTags, include every file
else
    include = cellfun(@(c)~isempty(intersect(c,includeTags)),tags);     % determine which mfiles to include based on their tags
end

excluded = mfiles(cellfun(@(c)~isempty(intersect(c,excludeTags)),tags));
excluded = cellfuncell(@(c)c(1:end-2), excluded);
if not(doformat)
    % when asked not to format, the semantics of excludeTags are
    % different - we actually exclude demos with any of these tags from
    % the list.
    exclude = cellfun(@(c)~isempty(intersect(c,excludeTags)),tags);
    text = mfiles(include & not(exclude));
    return;
end
mfiles = mfiles(include);                                              % keep only included mfiles
text = cellfuncell(@(c)sprintf('%s;%spclear(%d);',c(1:end-2),...       % format each example name by removing .m adding ';', spaces, and 'pclear('pauseTime');'
    blanks(max(5,42 - length(c))),pauseTime),mfiles)';
if ~isempty(excludeTags)                                               % if there are exclude tags
    comments = cellfuncell(@(c)catString(cellfuncell(@(s)regexprep...  % construct comments for mfiles with excludeTags from the tags themselves
        (s,'#',''),intersect(c,excludeTags)),' & '),tags(include));
    ndx = find((cellfun(@(c)~isempty(c),comments)));                   % indices into mfiles(include) of files with excludeTags and thus non-empty comments
    text(ndx) = cellfuncell(@(c)['%',c],text(ndx));                    % add a '%' to the beginning of each mfile name with an excludeTag
    for j=1:numel(ndx)
        i = ndx(j);
        text{i} = [text{i},' % ',comments{i}];                         % add comments to excluded mfiles
        text{i} = [text{i}(1:length(mfiles{i})),...                    % remove one extra space so pclear() statements line up
            text{i}(length(mfiles{i})+2:end)];
    end
end
text = [{''};text;{''}];                                               % Add an extra blank line at the top and bottom
end