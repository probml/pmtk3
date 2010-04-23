function errors = debugDemos(subFolder, exclusions)
% Debug the PMTK demos, by attempting to run them all, saving 
% a list of those which fail. Figures and output are not displayed, use
% runDemos or runAllDemos if you wish to see the output. 
shadowFunction({'pause', 'input', 'keyboard'});
cd(tempdir());
dbclear('if', 'error');
dbclear('if', 'warning');
if nargin < 1, subFolder = ''; end
if nargin < 2, exclusions = {'PMTKslow', 'PMTKinteractive'}; end
hideFigures
[demos, excluded] = processExamples({}, exclusions, 0, false, subFolder);
maxname = max(cellfun(@length, demos));
ndemos = numel(demos);
demos = cellfuncell(@(s)s(1:end-2), demos);
errors = struct();
htmlData = cell(ndemos+numel(excluded), 5);
htmlTableColors   = repmat({'lightgreen'}, ndemos, 5);
for dm=1:ndemos
    try
       htmlData{dm, 1} = demos{dm}; 
       fprintf('%d:%s %s%s',dm, repmat(' ', [1, 5-length(num2str(dm))]), ...
           demos{dm}, dots(maxname+5-length(demos{dm}))); 
       tic;   
       evalc(demos{dm});
       t = toc;
       fprintf('PASS\n');
       htmlData{dm, 2} = 'PASS';
       htmlData{dm, 5} = sprintf('%.1f seconds', t);
    catch ME
       errors.(demos{dm}) = ME;
       fprintf('FAIL\n');
       htmlData{dm, 2} = 'FAIL';
       htmlData{dm, 3} = ME.identifier;
       htmlData{dm, 4} = ME.message;
       htmlTableColors(dm, :) = {'red'};
    end
    clearvars -except demos errors dm htmlData htmlTableColors excluded ndemos maxname
    close all hidden
end
fprintf('%d out of %d failed\n', numel(fieldnames(errors)), numel(demos));
showFigures
for i = 1:numel(excluded)
    htmlData(ndemos+i, 1) = excluded(i);
    htmlData(ndemos+i, 2) = {'SKIP'};
    htmlTableColors(ndemos+i, :) = {'yellow'};
end
perm = sortidx(htmlData(:, 1));
htmlData = htmlData(perm, :);
htmlTableColors = htmlTableColors(perm, :);


htmlTable('data', htmlData, 'colNames', {'Name', 'Status', 'Error Identifier', 'Error Message', 'Time'}, 'dataColors', htmlTableColors);
removeShadows();
    
end