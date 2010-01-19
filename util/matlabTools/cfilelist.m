function [cfiles,info] = cfilelist(directory,cfiles)
% recursive function, collecting the name of every c-file in the current directory and
% subdirectory.
    if(nargin < 1);
        directory = '.';
    end
    if(nargin < 2)
        cfiles = {};
    end
    cf = dir([directory,'\*.c']);
    cfiles = {cf.name};
    info = what(directory);
    flist = dir(directory);
    dlist =  {flist([flist.isdir]).name};
    for i=1:numel(dlist)
        dirname = dlist{i};
        if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
            [newCfiles,newInfo] = cfilelist([directory,'\',dirname],cfiles);
            info = [info, newInfo];
            cfiles = [cfiles,newCfiles];
        end
    end
    
end