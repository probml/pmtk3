function printPmtkFigure(filename, format)
% print current figure to specified file in .pdf (or other) format

% This file is from pmtk3.googlecode.com

if nargin <2, format = 'pdf'; end

if false % set to false to turn off printing
   %printFolder = 'C:\kmurphy\dropbox\PML\Figures\pdfFigures';
   printFolder = '/Users/kpmurphy/MLbook/Figures/pdfFigures';
   if strcmpi(format, 'pdf')
       pdfcrop;
   end
    fname = sprintf('%s/%s.%s', printFolder, filename, format);
    fprintf('printing to %s\n', fname);
    if exist(fname,'file'), delete(fname); end % prevent export_fig from appending
    if 0
        %opts = struct('Color', 'rgb', 'Resolution', 1200, 'fontsize', 12);
        opts = struct('Color', 'rgb', 'Resolution', 1200);
        exportfig(gcf, fname, opts, 'Format', 'pdf' );
    else
        set(gca,'Color','none') % turn off gray background
        set(gcf,'Color','none')
        export_fig(fname)
    end
end

end
