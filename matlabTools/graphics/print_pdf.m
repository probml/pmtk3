%PRINT_PDF  Prints cropped figures to pdf with fonts embedded
%
% Examples:
%   print_pdf filename
%   print_pdf(filename, fig_handle)
%
% This function saves a figure as a pdf nicely, without the need to specify
% multiple options. It improves on MATLAB's print command (using default
% options) in several ways:
%   - The figure borders are cropped
%   - Fonts are embedded (as subsets)
%   - Lossless compression is used on vector graphics
%   - High quality jpeg compression is used on bitmaps
%   - Dotted/dashed line dash lengths vary with line width (as on screen)
%   - Grid lines given their own dot style, instead of dashed
%
% This function requires that you have ghostscript installed on your system
% and that the executable binary is on your system's path. Ghostscript can
% be downloaded from: http://www.ghostscript.com
%
%IN:
%   filename - string containing the name (optionally including full or
%              relative path) of the file the figure is to be saved as. A
%              ".pdf" extension is added if not there already. If a path is
%              not specified, the figure is saved in the current directory. 
%   fig_handle - The handle of the figure to be saved. Default: current
%                figure.
%
% Copyright (C) Oliver Woodford 2008

% This file is from pmtk3.googlecode.com


% This function is inspired by Peder Axensten's SAVEFIG (fex id: 10889)
% which is itself inspired by EPS2PDF (fex id: 5782)
% The idea of editing the EPS file to change line styles comes from Jiro
% Doke's FIXPSLINESTYLE (fex id: 17928)
% The idea of changing dash length with line width came from comments on
% fex id: 5743, but the implementation is mine :)

%PMTKauthor Oliver Woodford
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/22018

% $Id: print_pdf.m,v 1.25 2008/12/15 16:52:07 ojw Exp $

function print_pdf(name, fig)
if nargin < 2
    fig = gcf;
end
% Set paper size
set(fig, 'PaperPositionMode', 'auto');
% Print to eps file
tmp_nam = [tempname '.eps'];
print('-depsc2', '-noui', '-painters', ['-f' num2str(fig)], '-r864', tmp_nam);
% Fix the line styles
fix_lines(tmp_nam);
% Construct the filename
if numel(name) < 5 || ~strcmpi(name(end-3:end), '.pdf')
    name = [name '.pdf']; % Add the missing extension
end
% Construct the command string for ghostscript. This assumes that the
% ghostscript binary is on your path - you can also give the complete path,
% e.g. cmd = '"C:\Program Files\gs\gs8.63\bin\gswin32c.exe"';
cmd = 'gs';
if ispc
    cmd = [cmd 'win32c.exe'];
end
options = [' -q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' name '" -f "' tmp_nam '"'];
% Convert to pdf
[status result] = system([cmd options]);
% Check status
if status
    % Something went wrong
    if isempty(strfind(result, 'not recognized'))
        fprintf('%s\n', result);
    else
        % Ghostscript isn't on the path - try to find it
        cmd = find_ghostscript;
        if isempty(cmd)
            fprintf('Ghostscript not found.\n');
        else
            system([cmd options]);
        end
    end
end
% Delete the temporary file
delete(tmp_nam);
return
end
function cmd = find_ghostscript
% Find the full path to a ghostscript executable
cmd = '';
if ispc
    % For Windows, look in the default location
    default_location = 'C:\Program Files\gs\';
    executable = '\bin\gswin32c.exe';
else
    % This case isn't supported. Contact me if you have a fix.
    return
end
dir_list = dir(default_location);
ver_num = 0;
for a = 1:numel(dir_list)
    % If there are multiple versions, use the newest
    ver_num2 = sscanf(dir_list(a).name, 'gs%g');
    if ~isempty(ver_num2) && ver_num2 > ver_num
        cmd2 = [default_location dir_list(a).name executable];
        if exist(cmd2, 'file') == 2
            cmd = ['"' cmd2 '"'];
            ver_num = ver_num2;
        end
    end
end
return
end
function fix_lines(fname)
% Improve the style of lines used and set grid lines to an entirely new
% style using dots, not dashes

% Read in the file
fh = fopen(fname, 'rt');
fstrm = char(fread(fh)');
fclose(fh);

% Make sure all line width commands come before the line style definitions,
% so that dash lengths can be based on the correct widths
% Find all line style sections
ind = [regexp(fstrm, '[\n\r]SO[\n\r]'),... % This needs to be here even though it doesn't have dots/dashes!
       regexp(fstrm, '[\n\r]DO[\n\r]'),...
       regexp(fstrm, '[\n\r]DA[\n\r]'),...
       regexp(fstrm, '[\n\r]DD[\n\r]')];
ind = sort(ind);
% Find line width commands
[ind2 ind3] = regexp(fstrm, '[\n\r]\d* w[\n\r]', 'start', 'end');
% Go through each line style section and swap with any line width commands
% near by
b = 1;
m = numel(ind);
n = numel(ind2);
for a = 1:m
    % Go forwards width commands until we pass the current line style
    while b <= n && ind2(b) < ind(a)
        b = b + 1;
    end
    if b > n
        % No more width commands
        break;
    end
    % Check we haven't gone past another line style (including SO!)
    if a < m && ind2(b) > ind(a+1)
        continue;
    end
    % Are the commands close enough to be confident we can swap them?
    if (ind2(b) - ind(a)) > 8
        continue;
    end
    % Move the line style command below the line width command
    fstrm(ind(a)+1:ind3(b)) = [fstrm(ind(a)+4:ind3(b)) fstrm(ind(a)+1:ind(a)+3)];
    b = b + 1;
end

% Find any grid line definitions and change to GR format
% Find the DO sections again as they may have moved
ind = int32(regexp(fstrm, '[\n\r]DO[\n\r]'));
% Find all occurrences of what are believed to be axes and grid lines
ind2 = int32(regexp(fstrm, '[\n\r] *\d* *\d* *mt *\d* *\d* *L[\n\r]'));
% Now see which DO sections come just before axes and grid lines
ind2 = repmat(ind2', [1 numel(ind)]) - repmat(ind, [numel(ind2) 1]);
ind2 = any(ind2 > 0 & ind2 < 12); % 12 chars seems about right
ind = ind(ind2);
% Change any regions we believe to be grid lines to GR
fstrm(ind+1) = 'G';
fstrm(ind+2) = 'R';

% Isolate line style definition section
first_sec = findstr(fstrm, '% line types:');
[second_sec remaining] = strtok(fstrm(first_sec+1:end), '/');
[dummy remaining] = strtok(remaining, '%');

% Define the new styles, including the new GR format
% Dot and dash lengths have two parts: a constant amount plus a line width
% variable amount. The constant amount comes after dpi2point, and the
% variable amount comes after currentlinewidth. If you want to change
% dot/dash lengths for a one particular line style only, edit the numbers
% in the /DO (dotted lines), /DA (dashed lines), /DD (dot dash lines) and
% /GR (grid lines) lines for the style you want to change.
new_style = {'/dom { dpi2point 1 currentlinewidth 0.08 mul add mul mul } bdef',... % Dot length macro based on line width
             '/dam { dpi2point 2 currentlinewidth 0.04 mul add mul mul } bdef',... % Dash length macro based on line width
             '/SO { [] 0 setdash 0 setlinecap } bdef',... % Solid lines
             '/DO { [1 dom 1.2 dom] 0 setdash 0 setlinecap } bdef',... % Dotted lines
             '/DA { [4 dam 1.5 dam] 0 setdash 0 setlinecap } bdef',... % Dashed lines
             '/DD { [1 dom 1.2 dom 4 dam 1.2 dom] 0 setdash 0 setlinecap } bdef',... % Dot dash lines
             '/GR { [0 dpi2point mul 4 dpi2point mul] 0 setdash 1 setlinecap } bdef'}; % Grid lines - dot spacing remains constant
new_style = sprintf('%s\r', new_style{:});

% Save the file with the section replaced
fh = fopen(fname, 'wt');
fprintf(fh, '%s%s%s%s', fstrm(1:first_sec), second_sec, new_style, remaining);
fclose(fh);
return
end
