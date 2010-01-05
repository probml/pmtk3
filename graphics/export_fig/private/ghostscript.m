function varargout = ghostscript(cmd)
%GHOSTSCRIPT  Calls a local GhostScript executable with the input command
%
% Example:
%   [status result] = ghostscript(cmd)
%
% Attempts to locate a ghostscript executable, finally asking the user to
% specify the directory ghostcript was installed into. The resulting path
% is stored for future reference.
% 
% Once found, the executable is called with the input command string.
%
% This function requires that you have Ghostscript installed on your
% system. You can download this from: http://www.ghostscript.com
%
% IN:
%   cmd - Command string to be passed into ghostscript.
%
% OUT:
%   status - 0 iff command ran without problem.
%   result - Output from ghostscript.

% $Id: ghostscript.m,v 1.7 2009/04/21 17:30:47 ojw Exp $
% Copyright: Oliver Woodford, 2009

% Call ghostscript
[varargout{1:nargout}] = system(sprintf('"%s" %s', gs_path, cmd));
return

function path = gs_path
% Return a valid path
% Start with the currently set path
path = current_gs_path;
% Check the path works
if check_gs_path(path)
    return
end
% Check whether the binary is on the path
if ispc
    bin = 'gswin32c.exe';
else
    bin = 'gs';
end
if check_store_gs_path(bin)
    path = bin;
    return
end
% Search the obvious places
if ispc
    default_location = 'C:\Program Files\gs\';
    executable = '\bin\gswin32c.exe';
    dir_list = dir(default_location);
    ver_num = 0;
    % If there are multiple versions, use the newest
    for a = 1:numel(dir_list)
        ver_num2 = sscanf(dir_list(a).name, 'gs%g');
        if ~isempty(ver_num2) && ver_num2 > ver_num
            path2 = [default_location dir_list(a).name executable];
            if exist(path2, 'file') == 2
                path = path2;
                ver_num = ver_num2;
            end
        end
    end
else
    path = '/usr/local/bin/gs';
end
if check_store_gs_path(path)
    return
end
% Ask the user to enter the path
while 1
    base = uigetdir('/', 'Ghostcript not found. Please select ghostscript installation directory.');
    if isequal(base, 0)
        % User hit cancel or closed window
        break;
    end
    base = [base filesep];
    bin_dir = {'', ['bin' filesep], ['lib' filesep]};
    for a = 1:numel(bin_dir)
        path = [base bin_dir{a} bin];
        if exist(path, 'file') == 2
            break;
        end
    end
    if check_store_gs_path(path)
        return
    end
end
error('Ghostscript not found.');

function good = check_store_gs_path(path)
% Check the path is valid
good = check_gs_path(path);
if ~good
    return
end
% Update the current default path to the path found
fname = which(mfilename);
% Read in the file
fh = fopen(fname, 'rt');
fstrm = fread(fh, '*char')';
fclose(fh);
% Find the path
first_sec = regexp(fstrm, '[\n\r]*function path = current_gs_path[\n\r]*path = ''', 'end', 'once');
second_sec = first_sec + regexp(fstrm(first_sec+1:end), ''';[\n\r]*return', 'once');
if isempty(first_sec) || isempty(second_sec)
    warning('Path to ghostscript installation could not be saved. Enter it manually in ghostscript.m.');
    return
end
% Save the file with the path replaced
fh = fopen(fname, 'wt');
fprintf(fh, '%s%s%s', fstrm(1:first_sec), path, fstrm(second_sec:end));
fclose(fh);
return

function good = check_gs_path(path)
% Check the path is valid
[good message] = system(sprintf('"%s" -h', path));
good = good == 0;
return

function path = current_gs_path
path = 'gswin32c.exe';
return