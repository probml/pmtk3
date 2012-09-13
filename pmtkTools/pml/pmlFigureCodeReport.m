function pmlFigureCodeReport(dest, includeEx, includeSol)
%% Generate an html report of figures in PML and their source files
%
%% Inputs
%
% dest   - this script creates a whole directory structure, specify the root
%          destination.
%
% includeEx   - [false] if true, pml exercises are included
% includeSol  - [false] if true, pml solutions are included
%
%% Example
% pmlFigureCodeReport('C:\users\Matt\Desktop', false, false)
%% source info

% This file is from pmtk3.googlecode.com

%if nargin < 1, dest = '/Users/Matt/Documents/MATLAB/figureReport'; end
if nargin < 1, dest = '/Users/kpmurphy/Dropbox/MLbook/Figures'; end
if nargin < 2, includeEx  = true; end
if nargin < 3, includeSol  = false; end

linkOtherSource = true; % if true, we link to tex, ppt, source etc.
oext = {'*.tex', '*.ppt'}; % look for files with these extensions if linkOtherSource true
figThanksText = 'Figure courtesy of';
figTakenText = 'Figure taken from';
figsThanksText = 'Figures courtesy of';
figsTakenText = 'Figures taken from';


bookSource = getConfigValue('PMTKpmlBookSource');
figs = getConfigValue('PMTKpmlFigures');
figSource  = fullfile(figs, 'figuresSource');
pdfSource  = fullfile(figs, 'pdfFigures');
%figSource  = fullfile(fileparts(bookSource), 'Figures', 'figuresSource');
%pdfSource  = fullfile(fileparts(bookSource), 'Figures', 'pdfFigures');

if linkOtherSource
    otherSrcFiles = filelist(figSource, oext, true);
    findOtherSrc = @(f)otherSrcFiles(cellfind(fnameOnly(otherSrcFiles), f));
end

%% gather figure info from pml
fprintf('gathering figure details from pml...');
F       = pmlFigureInfo(includeEx, includeSol);
Finfo   = [F{:}];
modDate = pmlGetLastModDate();
fprintf('done\n');
%% make dest directories
fullDest = fullfile(dest, ['figReport-', modDate]);
if ~exist(fullDest, 'dir')
    mkdir(fullDest);
end
pdfDest = fullfile(fullDest, 'pdfFigures');
figDest = fullfile(fullDest, 'figuresSource');
if ~exist(pdfDest, 'dir')
    mkdir(pdfDest);
end
if ~exist(figDest, 'dir')
    mkdir(figDest);
end
%% gather google docs info
[googleSourceImages, googleSourceURLs] = googleDocsSource(); 

%% gather html report data and copy files
nfigs = numel(Finfo);
missingSource = false(nfigs, 1);
htmlData = cell(nfigs, 1);
fprintf('copying pdf figures and source files...');
for i=1:nfigs
    fig            = Finfo(i);
    %% column 1
    htmlData{i, 1} = fig.figNumTxt;
    %% column 2
    fnames         = fig.fnames;
    fnameLink      = '';
    for j=1:numel(fnames)
        fpdf      = [fnames{j}, '.pdf'];
        src       = fullfile(pdfSource, fpdf);
        dst       = fullfile(pdfDest, fpdf);
        if isunix
          system(sprintf('cp %s %s', src, dst));
        else
          system(sprintf('copy %s %s', src, dst));
        end
        plink     = sprintf('<a href = %s/%s>%s</a>', fnameOnly(pdfDest), fpdf, fnames{j});
        fnameLink = sprintf('%s%s<br>', fnameLink, plink);
    end
    htmlData{i, 2} = fnameLink;
    %% column 3
    
    sourceLink = '';  
    for j=1:numel(fnames)  %% add in google code links if any
        src = fnames{j};
        [~, loc] = ismember(src, googleSourceImages);
        if (loc)
            sourceLink = sprintf('%s<a href = %s>%s</a><br>',sourceLink, googleSourceURLs{loc}, src); 
        end
    end
    codeNames = fig.codeNames;
    if ~isempty(codeNames)
        for j=1:numel(codeNames)
            gcl = googleCodeLink(codeNames{j});
            if isempty(gcl)
                sourceLink = sprintf('%s%s.m<br>', sourceLink, codeNames{j});
            else
                sourceLink = sprintf('%s%s<br>', sourceLink, gcl);
            end
        end
    elseif ~isempty(fig.macros.figthanks) && isempty(sourceLink)
        text = figThanksText;
        if (numel(fnames) > 1)
            text = figsThanksText; 
        end
        sourceLink = sprintf('%s %s', text, fig.macros.figthanks{1}); 
    elseif ~isempty(fig.macros.figtaken) && isempty(sourceLink)
        text = figTakenText; 
        if (numel(fnames) > 1)
            text = figsTakenText;
        end
        sourceLink = sprintf('%s %s', text, fig.macros.figtaken{1});
    elseif linkOtherSource
        found = false;
        src = [];
        fnames = [fig.label; fig.fnames(:)];
        for j=1:numel(fnames)
            src = [src;  findOtherSrc(fnames{j})]; %#ok
        end
        src = removeDuplicates(src);
        if ~isempty(src)
            found = true;
            for j=1:numel(src)
              if isunix
                system(sprintf('cp %s %s', src{j}, figDest));
              else
                system(sprintf('copy %s %s', src{j}, figDest));
              end
                sourceLink = sprintf('%s<a href = %s/%s>%s</a><br>', ...
                    sourceLink, 'figuresSource', fnameOnly(src{j}, true), ...
                    fnameOnly(src{j}, true));
            end
        end
        missingSource(i) = ~found;
    else  % unreachable!
        missingSource(i) = true;
    end
    htmlData{i, 3} = sourceLink;
end
fprintf('done\n');
fprintf('generating html report...');

%% Add chapter breaks
pmtkRed = getConfigValue('PMTKred');
figsPerCh = cellfun('length', F);
figsPerCh(figsPerCh == 0) = [];
ndx = cumsum(figsPerCh+1); 
htmlData = insertBlankCells(htmlData, ndx); 
blanks = cellfun(@isempty, htmlData);
htmlData(blanks) = {'&nbsp;'};
colors  = repmat({'white'}, size(htmlData)); 
colors(ndx, :) = {pmtkRed}; 
colSpan = zeros(size(htmlData, 1), 1); 
colSpan(ndx) = 1;

%% create html report

header = formatHtmlText(...
{    
'<font align="left" style="color:%s"><h2>Figures from "Machine Learning: a Probabilistic Perspective"</h2></font>' 
''
'Auto-generated by %s.m on %s from book version of %s'
''
'Click on a filename to download a file.'
'Image files are in pdf format.'
'Source files ending in .m are matlab.'
'Source files ending in .ppt are powerpoint.'
'Source files ending in .tex are latex (needs pstricks).'
'Source files with no file extension are (pointers to) google docs drawings.'
'Images without source files are hand-drawn or taken from other sources.'
''
'Total number of figures: %d'
''
''
}, pmtkRed, mfilename, date, modDate, numel(Finfo)); 

outputFile = fullfile(fullDest, 'pmlFigureCodeTable.html');
colNames = {'Figure Number', 'Image Files', 'Source Files'};
htmlTable(  'data'          , htmlData                     , ...
            'header'        , header                       , ...
            'dataAlign'     , 'left'                       , ...
            'colNames'      , colNames                     , ...
            'colNameColors' , {pmtkRed, pmtkRed, pmtkRed}  , ...
            'doSave'        , true                         , ...
            'filename'      , outputFile                   , ...
            'doShow'        , false                        , ...
            'dataColors'    , colors                       , ...
            'colSpan'       , colSpan);
fprintf('done\n');
%% missing source figures
%{
if any(missingSource)
    missing = Finfo(missingSource);
    missingData = cell(numel(missing), 2);
    for i=1:numel(missing)
        missingData{i, 1} = missing(i).figNumTxt;
        missingData{i, 2} = missing(i).fnames;
    end
    
    fprintf('creating missing source file report...');
    header = [...
        sprintf('<font align="left" style="color:%s"><h2>Missing Source Files</h2></font>\n', pmtkRed),...
        sprintf('<br>Revision Date: %s<br>\n', date()),...
        sprintf('<br>PML version: %s<br>\n', modDate), ...
        sprintf('<br>Auto-generated by %s.m<br>\n', mfilename()),...
        sprintf('<br>\n')...
        ];
    
    outputFile = fullfile(fullDest, 'pmlMissingSourceFiles.html');
    colNames = {'Figure Number', 'Source Files'};
    htmlTable(  'data'          , missingData, ...
        'header'          , header                       , ...
        'dataAlign'     , 'left'                       , ...
        'colNames'      , colNames                     , ...
        'colNameColors' , {pmtkRed, pmtkRed, pmtkRed}  , ...
        'doSave'        , true                         , ...
        'filename'      , outputFile                   , ...
        'doShow'        , false);
    
    fprintf('done\n');
end
%}
%% copy pml.pdf if it exists
%{
fprintf('copying pml.pdf...')
if exist(fullfile(bookSource, 'pml.pdf'), 'file')
    src = fullfile(bookSource, 'pml.pdf');
    dst =  fullfile(fullDest, sprintf('pml%s.pdf', modDate));
    system(sprintf('copy %s %s', src , dst)); 
    fprintf('done\n');
else
    fprintf('pml.pdf could not be found\n');
end
%}
%% call pmlMissingCodeReport
fprintf('calling pmlMissingCodeReport...');
outputfile = fullfile(fullDest, 'pmlMissingCodeReport.html'); 
%try
pmlMissingCodeReport(bookSource, false, outputfile); 
fprintf('done\n');
%catch %#ok
%   fprintf('Could not run pmlMissingCodeReport'); 
%end

end
