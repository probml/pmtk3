function errors = debugDemos()
% Debug the PMTK demos, by attempting to run them all, saving 
% a list of those which fail. 
mlock
demos = processExamples({}, {}, 0, false);
demos = cellfuncell(@(s)s(1:end-2), demos);
errors = struct();
for i=1:numel(demos)
    try
        evalc(demos{i});
        fprintf('PASS\t%s\n', demos{i});
    catch ME
        errors.demos = ME;
        fprintf('FAIL\t%s\n', demos{i});
    end
    close all
end
    
    
    
end