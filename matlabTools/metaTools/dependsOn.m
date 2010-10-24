function [functionList, classList] = dependsOn(mfile, dirRoot)
% Find dependencies on a directory structure for a single file
%%

% This file is from pmtk3.googlecode.com


dependencies = depfunTB(mfile);

functionList = {};
classList = {};
for i=1:numel(dependencies)
    try
        fid = fopen(dependencies{i});
        fulltext = textscan(fid,'%s','delimiter','\n','whitespace','');
        fclose(fid);
        fulltext = fulltext{:};
        [path,name] = fileparts(dependencies{i});
        if(isempty(cell2mat(strfind(fulltext,'classdef'))))
            functionList = [functionList;name];
        else
            classList = [classList;name];
        end
    catch
    end
end
classList = sort(classList');
functionList = sort(functionList');



    function filelist = depfunTB(filename)
        %Like builtin depfun except it only returns dependencies on the
        %specified toolbox and is thus much faster. Based on exportToZip by
        %Malcolm Wood available in the Mathworks file exchange. Altered
        %significantly here.
        filelist = depScan(filename);
        toscan = filelist;
        while numel(toscan)>0
            if(not(strncmpi(toscan{1},dirRoot,numel(dirRoot))))
                newlist = depScan(toscan{1});
                toscan(1) = [];
                newlist = newlist(not(ismember(newlist,filelist)));
                toscan = unique( [ toscan ; newlist ] );
                filelist = [ filelist ; newlist ];
            else
                toscan(1) = [];
            end
        end
    end %end of depfunTB


    function list = depScan(func,invert)
        % Returns all of the files the specified func calls that are either in
        % or not in the specified directory structure, depending on the truth
        % of the third parameter, invert. invert is false if not specified.
        if(nargin < 2), invert = false; end
        
        
        %             [list, builtins, classes, prob_files, prob_sym,...
        %                 eval_strings,called_from, java_classes]  = ...
        %                 depfun(func,'-toponly','-quiet');
        [pathstr,func] = fileparts(func);
        list = depfun(func,'-toponly','-quiet');
        list(1) = []; %func is always at the top of the list
        
        intoolbox = strncmpi(list,dirRoot,numel(dirRoot));
        if(invert)
            matlabpath = fullfile(matlabroot,'toolbox','matlab');
            matlab = strncmpi(list,matlabpath,numel(matlabpath));
            list = list(~matlab & ~intoolbox);
        else
            list = list(intoolbox);
        end
    end %end of depScan
end %end of file
