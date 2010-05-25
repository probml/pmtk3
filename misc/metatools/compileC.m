function compileC()
% Try and compile all mexable c-files in the pmtk directory structure
% PMTKneedsMatlab 
cd(pmtk3Root());
exclusions = {fullfile(pmtk3Root(), 'foreign\Minka\fastfit');
    fullfile(pmtk3Root(), 'toolbox\gaussianProcesses\gpml')
    };
cfiles = cfilelist();
for i=1:numel(exclusions)
    cfiles = setdiff(cfiles, cfilelist(exclusions{i}));
end
cfiles = setdiff(cfiles, cfilelist());
for j=1:numel(cfiles)
    try
        cfile = which(cfiles{j});
        cd(fileparts(cfile));
        fprintf('Compiling %s\n',cfile);
        mex(cfile);
    catch ME
        fprintf('Could not compile %s\n', cfile);
    end
end
end
