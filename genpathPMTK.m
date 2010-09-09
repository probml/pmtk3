function p = genpathPMTK(d, isMatlab)
% Like built-in genpath, but omits directories unwanted directories:
% e.g. .svn, cvs, private, deprecated, +package
% For best performance, optionally specify whether this is Matlab, (as
% opposed to Octave). 
%%

% This file is from pmtk3.googlecode.com

if nargin==0,
    p = genpath(fullfile(matlabroot, 'toolbox'));
    if length(p) > 1,
        p(end) = [];
    end % Remove trailing pathsep
    return
end

if nargin > 1 && ~isMatlab %isempty(strfind(upper(matlabroot), 'MATLAB')) % octave
    p = genpath(d); % genpathPMTK is not reliable in Octave
   return; 
end
    
% initialise variables
methodsep = '@';  % qualifier for overloaded method directories
p = '';           % path to be returned

% Generate path based on given root directory
files = dir(d);
if isempty(files)
    return
end

% Add d to the path even if it is empty.
p = [p d pathsep];

% set logical vector for subdirectory entries in d
isdir = logical(cat(1, files.isdir));
%
% Recursively descend through directories which are neither
% private nor "class" directories.
%
dirs = files(isdir); % select only directory entries from the current listing
for i=1:length(dirs)
   dirname = dirs(i).name;
   if    ~strcmp(  dirname , '.')          && ...
         ~strcmp(  dirname , '..')         && ...
         ~strncmp( dirname , methodsep, 1) && ...
         ~strcmp(  dirname , 'private')    && ...
         ~strcmp(  dirname , 'deprecated') && ...
         ~strcmp(  dirname , '.svn')       && ...
     	 ~strcmp(  dirname , 'CVS')        && ...
         ~strncmp( dirname , '+', 1)
         p = [p genpathPMTK(fullfile(d, dirname))]; %#ok recursive calling of this function.
   end
end
end


% function p = genpathOctave(d)
% %% Prototoype version that may not work reliably
% 
% fullp = genpath(d); 
% 
% [start, finish] = regexp(fullp, pathsep);
% if isempty(start)
%     tokens = {fullp};
% else
%     tokens = cell(numel(start+1), 1);
%     tokens{1} = fullp(1:start(1)-1);
%     start = [start, length(fullp)+1];
%     for i=1:numel(finish)
%         tokens{i+1} = fullp(finish(i)+1:start(i+1)-1);
%     end
% end
% tokens(cellfun(@(c)isempty(c), tokens)) = []; 
% ndx = cellfun(@(c)~isempty(c), strfind(tokens, '.svn'));
% tokens(ndx) = [];
% tokens = cellfun(@(t)[t, pathsep], tokens, 'uniformoutput', false); 
% p = [tokens{:}]; 
% if isempty(p)
%     p = '';
% end
% 
% end
