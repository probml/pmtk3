function files = listPackageFiles(directory)
%% Return a list of all package m files in the directory structure. 
contrib = cellfuncell(@fileparts, filelist(directory, 'Contents.m', true));
files = cellfuncell(@(d)filelist(d, '*.m', false), contrib);
files = vertcat(files{:}); 

end