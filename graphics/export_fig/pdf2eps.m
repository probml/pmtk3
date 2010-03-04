%PDF2EPS  Convert a pdf file to eps format using pdftops
%
% Examples:
%   pdf2eps source dest
%
% This function converts a pdf file to eps format.
%
% This function requires that you have pdftops, from the Xpdf suite of
% functions, installed on your system. This can be downloaded from:
% http://www.foolabs.com/xpdf  
%
%IN:
%   source - filename of the source pdf file to convert. The filename is
%            assumed to already have the extension ".pdf".
%   dest - filename of the destination eps file. The filename is assumed to
%          already have the extension ".eps".

% Copyright (C) Oliver Woodford 2009

% $Id: pdf2eps.m,v 1.2 2009/04/19 21:48:42 ojw Exp $

function pdf2eps(source, dest)
% Construct the options string for pdftops
options = ['-q -paper match -pagecrop -eps -level2 "' source '" "' dest '"'];
% Convert to eps using pdftops
pdftops(options);
% Fix the DSC error created by pdftops
fid = fopen(dest, 'r+');
if fid == -1
    % Cannot open the file
    return
end
fgetl(fid); % Get the first line
str = fgetl(fid); % Get the second line
if strcmp(str(1:min(13, end)), '% Produced by')
    fseek(fid, -numel(str)-1, 'cof');
    fwrite(fid, '%'); % Turn ' ' into '%'
end
fclose(fid);
return

end