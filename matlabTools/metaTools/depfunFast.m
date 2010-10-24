function filelist = depfunFast(fn,recursive)
% Variation on the built-in depfun function, which skips toolbox files
%
% filelist = mydepfun(fn)
% filelist = mydepfun(fn,recursive)
%
% Returns a list of files which are required by the specified
% function, omitting any which are inside $matlabroot/toolbox. 
%
% "fn" is a string specifying a filename in any form that can be
%   identified by the built-in function "which".
% "recursive" is a logical scalar; if false, only the files called
%   directly by the specified function are returned.  If true, *all*
%   those files are scanned to, and any required by those, and so on.
%
% "filelist" is a cell array of fully qualified file name strings,
%   including the specified file.
%
% e.g.
%     filelist = mydepfun('myfunction')
%     filelist = mydepfun('C:\files\myfunction.m',true) 
%PMTKauthor Malcolm Wood
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/10702

% This file is from pmtk3.googlecode.com


if ~ischar(fn)
    error('First argument must be a string');
end

foundfile = which(fn);
if isempty(foundfile)
    error('File not found: %s',fn);
end

% Scan this file
filelist = i_scan(foundfile);

% If "recursive" is supplied and true, scan files on which this one depends.
if nargin>1 && recursive
    % Create a list of files which we have still to scan.
    toscan = filelist;
    toscan = toscan(2:end); % first entry is always the same file again
    % Now scan files until we have none left to scan
    while numel(toscan)>0
        % Scan the first file on the list
        newlist = i_scan(toscan{1});
        newlist = newlist(2:end); % first entry is always the same file again
        toscan(1) = []; % remove the file we've just scanned
        % Find out which files are not already on the list.  Take advantage of
        % the fact that "which" and "depfun" return the correct capitalisation
        % of file names, even on Windows, making it safe to use "ismember"
        % (which is case-sensitive).
        reallynew = ~ismember(newlist,filelist);
        newlist = newlist(reallynew);
        % If they're not already in the file list, we'll need to scan them too.
        % (Conversely, if they ARE in the file list, we've either scanned them
        %  already, or they're currently on the toscan list)
        toscan = unique( [ toscan ; newlist ] );
        filelist = unique( [ filelist ; newlist ] );
    end
end
end
%%%%%%%%%%%%%%%%%%%%%
% Returns the non-toolbox files which the specified one calls.
% The specified file is always first in the returned list.
function list = i_scan(f)

func = i_function_name(f);

list = depfun(func,'-toponly','-quiet');
ulist = lower(list);

toolboxroot = lower(fullfile(matlabroot,'toolbox'));

intoolbox = strncmp(ulist,toolboxroot,numel(toolboxroot));

list = list(~intoolbox);
end
%%%%%%%%%%%%%%%%%%%%%%%%
function func = i_function_name(f)
% Identifies the function name for the specified file,
% including the class name where appropriate.  Does not
% work for UDD classes, e.g. @rtw/@rtw

[dirname,funcname,ext] = fileparts(f);
[ignore,dirname] = fileparts(dirname);

if ~isempty(dirname) && dirname(1)=='@'
    func = [ dirname '/' funcname ];
else
    func = funcname;
end
end
