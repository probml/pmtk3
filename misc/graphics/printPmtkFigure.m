function printPmtkFigure(filename)
% print current figure to specified file in .eps and .pdf formats

if false
  % set to false to turn off printing
   %printFolder = 'C:\kmurphy\PML\Figures\pdfFigures';
   printFolder = 'C:\kmurphy\dropbox\PML\Figures\pdfFigures';
  %pdfcrop;
  %opts = struct('Color', 'rgb', 'Resolution', 1200);
  % try/catch not supported by old versions of matlab...
  %try
    fname = sprintf('%s/%s.pdf', printFolder, filename);
    fprintf('printing to %s\n', fname);
    if exist(fname,'file'), delete(fname); end % prevent export_fig from appending
    %exportfig(gcf, fname, opts, 'Format', 'pdf' );
    set(gca,'Color','none')
    set(gcf,'Color','none')
    export_fig(fname)
 %catch ME
    % could silently return instead...
  %  fprintf('could not print to %s/%s\n', printFolder, filename);
  %end
end

end