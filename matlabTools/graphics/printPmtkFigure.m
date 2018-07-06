function printPmtkFigure(filename, format, printFolder) %#ok
% print current figure to specified file in .pdf (or other) format

% This file is from pmtk3.googlecode.com

%return; % uncomment this to enable printing

if nargin <2, format = 'pdf'; end
if nargin < 3, printFolder = []; end
if isempty(printFolder)
  if ismac
    %printFolder = '/Users/kpmurphy/Dropbox/MLbook/Figures/pdfFigures';
    %printFolder = '/Users/kpmurphy/GDrive/Backup/MLbook/book2.0/Figures/pdfFigures';
    printFolder = '/Users/kpmurphy/github/pmtk3/figures';
  else
    %error('need to specify printFolder')
    if exist('default_print_folder', 'dir')~=7
      mkdir 'default_print_folder';
    end
    printFolder = fullfile(pwd, 'default_print_folder');
  end
end

if strcmpi(format, 'pdf')
  pdfcrop(gcf, 0, 0);
end

complete_filename = sprintf('%s.%s', filename, format);
fname = fullfile(printFolder, complete_filename);

fprintf('printing to %s\n', fname);
if exist(fname,'file'), delete(fname); end % prevent export_fig from appending
if 0
  %opts = struct('Color', 'rgb', 'Resolution', 1200, 'fontsize', 12);
  opts = struct('Color', 'rgb', 'Resolution', 1200);
  exportfig(gcf, fname, opts, 'Format', 'pdf' );
end
if 0
  set(gca,'Color','none') % turn off gray background
  set(gcf,'Color','none')
  export_fig(fname)
end
if 1
   print(gcf, '-dpdf', fname);
end

end
