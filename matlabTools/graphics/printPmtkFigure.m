function printPmtkFigure(filename)
% print current figure to specified file in .pdf format

% This file is from pmtk3.googlecode.com


if false % set to false to turn off printing
   %printFolder = 'C:\kmurphy\dropbox\PML\Figures\pdfFigures';
   printFolder = '/Users/kpmurphy/MLbook/Figures/pdfFigures';
  pdfcrop;
    fname = sprintf('%s/%s.pdf', printFolder, filename);
    fprintf('printing to %s\n', fname);
    if exist(fname,'file'), delete(fname); end % prevent export_fig from appending
    if 1
        %opts = struct('Color', 'rgb', 'Resolution', 1200, 'fontsize', 12);
        opts = struct('Color', 'rgb', 'Resolution', 1200);
        exportfig(gcf, fname, opts, 'Format', 'pdf' );
    else
        set(gca,'Color','none')
        set(gcf,'Color','none')
        export_fig(fname)
    end
end

end
