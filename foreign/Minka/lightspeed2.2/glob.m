function [names,isdirs] = glob(pattern,prefix)
%GLOB   Filename expansion via wildcards.
% GLOB(PATTERN) returns a cell array of file/directory names which match the 
% PATTERN.  
% [NAMES,ISDIRS] = GLOB(PATTERN) also returns a logical vector indicating 
% which are directories.
%
% Two types of wildcards are supported:
% * matches zero or more characters, besides /
% ** matches zero or more characters, including /, ending with a /
% *** is interpreted as ** followed by *, which means it matches zero or
% more characters, including /
%
% For example, 'a*b' matches 'ab','acb','acdb', but not 'a/b'.
% 'a**b' matches 'ab','a/b','ac/b','ac/d/b', but not 'acb' or 'a/cb'.
% 'a***b' matches all of the above plus 'a/cb','ac/d/cb',etc.
%
% 'a//b' is not considered a valid filename, so 'a/*/b' will not return
% 'a//b' or 'a/b'.
%
% Examples:
%   % if 'work' is a subdirectory, this returns only 'work', not its contents:
%   glob('work')
%   % returns 'work/fun.m' (not 'fun.m'):
%   glob('work/fun.m')
%   % all m-files in 'work', prefixed with 'work/':
%   glob('work/*.m')
%   % all files named 'fun.m' in 'work' or any subdirectory of 'work':
%   glob('work/**fun.m') 
%   % all m-files in 'work' or any subdirectory of 'work':
%   glob('work/***.m')
%   % all files named 'fun.m' any subdirectory of 'work' (but not 'work'):
%   glob('work/**/fun.m') 
%   % all files named 'fun.m' in any subdirectory of '.':
%   glob('**fun.m') 
%   % all files in all subdirectories:
%   glob('***') 
%
% See also globstrings.

% Written by Tom Minka, 28-Apr-2004 (revised 2007)
% (c) Microsoft Corporation. All rights reserved.

if nargin < 2
  prefix = '';
end

names = {};
isdirs = [];
if isempty(pattern)
  return
end

% break the pattern into path components
[first,rest] = strtok(pattern,'/');
% when recursing, remove the leading / from rest
if ~isempty(rest)
  rest = rest(2:end);
end
% special case for absolute paths
if pattern(1) == '/'
  prefix  = '/';
end
% absolute path tests:
% glob('/*.sys')
% glob('/sho/**/*.sln')
% glob('/sho***.sln')

i = strfind(first,'**');
if ~isempty(i)
  % double-star pattern
  i = i(1); % process first occurrence
  rest = fullfile(first((i+2):end),rest);
  first = first(1:(i-1));
  new_pattern = [first rest];
  % if the pattern was 'a**b/c', new_pattern is 'ab/c'
  [names,isdirs] = glob(new_pattern,prefix);
  first = [first '*'];
  rest = ['**' rest];
  % if the pattern was 'a**b/c', it is now 'a*/**b/c'
end

% expand the first component
fullfirst = fullfile(prefix,first);
if ~iswild(fullfirst) & isdir(fullfirst)
  first_files = struct('name',first,'isdir',1);
else
  first_files = stripdots(dir(fullfirst));
end
% for each match, add it to the results or recurse on the rest of the pattern
for i = 1:length(first_files)
  new_prefix = fullfile(prefix,first_files(i).name);
  if isempty(rest)
    names{end+1} = new_prefix;
    isdirs(end+1) = first_files(i).isdir;
  elseif first_files(i).isdir
    [new_names, new_isdirs] = glob(rest,new_prefix);
    names = cellcat(names, new_names);
    isdirs = [isdirs; new_isdirs];
  end
end
names = names(:);
isdirs = isdirs(:);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function files = stripdots(files)
% omit . and .. from the results of DIR

names = {files.name};
ok = (~strcmp(names,'.') & ~strcmp(names,'..'));
files = files(ok);

function c = cellcat(c,c2)

c = {c{:} c2{:}};

function tf = iswild(pattern)

tf = ~isempty(strfind(pattern,'*'));

function s = regexp_quote(s)

regexprep(s,'[!#]^','#^');
regexprep(s,'[!#]$','#$');
