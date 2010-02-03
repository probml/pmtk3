function demos = makeRunAllDemos()
% This function automatically generates the runDemos.m file, which contains
% code to run all of the PMTK scripts located in the demos directory. 
% All of the work is done in processExamples(). 

    fname = 'runAllDemos.m';                    % name of the file to create
    includeTags = {};                           % include everything
    excludeTags = {'#broken','#inprogress'};    % commented out in runDemos.m
    pauseTime = 2;                              % time in seconds to pause between consecutive demos

    demos = processExamples(includeTags,excludeTags,pauseTime);
    demos = demos(sortidx(lower(demos)));
    header = {'%% Run Every Demo'};
    footer = {''};
    fulltext = [header;demos;footer];
    writeText(fulltext,fullfile(pmtk3Root(),'util',fname)); 


end