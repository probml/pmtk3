%EPS2PDF  Convert an eps file to pdf format using ghostscript
%
% Examples:
%   eps2pdf source dest
%
% This function converts an eps file to pdf format. If the output pdf file
% already exists, the eps file is appended as a new page on the end of the
% eps file.
%
% This function requires that you have ghostscript installed on your
% system. Ghostscript can be downloaded from: http://www.ghostscript.com
%
%IN:
%   source - filename of the source eps file to convert. The filename is
%            assumed to already have the extension ".eps".
%   dest - filename of the destination pdf file. The filename is assumed to
%          already have the extension ".pdf".

% Copyright (C) Oliver Woodford 2009

% Suggestion of appending pdf files provided by Matt C at:
% http://www.mathworks.com/matlabcentral/fileexchange/23629

% $Id: eps2pdf.m,v 1.2 2009/04/19 21:48:42 ojw Exp $

function eps2pdf(source, dest)
% Check if the output file exists
if exist(dest, 'file') == 2
    % File exists, so append current figure to the end
    tmp_nam = tempname;
    % Copy the file
    copyfile(dest, tmp_nam);
    % Construct the options string for ghostscript
    options = ['-q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' dest '" "' tmp_nam '" "' source '"'];
    try
        % Convert to pdf using ghostscript
        ghostscript(options);
    catch
        % Delete the intermediate file
        delete(tmp_nam);
        rethrow(lasterror);
    end
    % Delete the intermediate file
    delete(tmp_nam);
else
    % File doesn't exist
    % Construct the options string for ghostscript
    options = ['-q -dNOPAUSE -dBATCH -dEPSCrop -sDEVICE=pdfwrite -dPDFSETTINGS=/prepress -sOutputFile="' dest '" "' source '"'];
    % Convert to pdf using ghostscript
    ghostscript(options);
end
return

end