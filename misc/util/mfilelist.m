function [info,mfiles] = mfilelist(directory,mfiles)
% recursive function, collecting the name of every m-file in the current directory and
% subdirectory.
    if(nargin < 1);
        directory = '.';
    end
    if(nargin < 2)
        mfiles = {};
    end
    mf = dir([directory,filesep(),'*.m']);
    mfiles = {mf.name};
    info = what(directory);
    flist = dir(directory);
    dlist =  {flist([flist.isdir]).name};
    for i=1:numel(dlist)
        dirname = dlist{i};
        if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
            [newInfo,newMfiles] = mfilelist([directory,filesep(),dirname],mfiles);
            info = [info, newInfo];
            mfiles = [mfiles,newMfiles];
        end
    end
    
end