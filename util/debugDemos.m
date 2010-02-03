function errors = debugDemos()
% Debug the PMTK demos, by attempting to run them all, saving 
% a list of those which fail. 

hideFigures
demos = processExamples({}, {'#slow'}, 0, false);
demos = cellfuncell(@(s)s(1:end-2), demos);
errors = struct();
for dm=1:numel(demos)
    try
       evalc(demos{dm});
       fprintf('%d:PASS\t%s\n', dm, demos{dm});
    catch ME
       errors.(demos{dm}) = ME;
       fprintf('%d:FAIL\t%s\n', dm, demos{dm});
    end
    clearvars -except demos errors dm
    close all
end
fprintf('%d out of %d failed\n', numel(fieldnames(errors)), numel(demos));
showFigures


    
end