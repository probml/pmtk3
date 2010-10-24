function [report,errors] = deptoolbox(toolboxname,isroot,visualize)
% Generate a toolbox dependency report for the current working directory
% and all of its subdirectories. That is, scan through every m-file in the
% current directory and all subdirectories and identify dependencies that
% these file have on the specified toolbox. Works for all m-files including
% class definitions. The search is m-file based and thus will work even
% when multiple functions are defined or even nested in a single file. 
%
% Running deptoolbox without any parameters will generate a report of all
% dependencies on files external to the current working directory's
% directory structure, (except built in matlab functions).
%
% toolboxname - the name of the toolbox, e.g. 'stats', 'bioinfo' , 'optim',
%               'nnet', 'symbolic', 'images', 'signal', etc. 
%
% isroot      - an optional parameter, if true, toolboxname is taken to be
%               a full directory path, e.g. 
%               C:\Program Files\MATLAB\R2008a\toolbox\stats\
%               This can be used to identify dependencies on an arbitrary
%               group of files all located within a single directory
%               structure. 
%              
% report      - a structure with two fields: filename and dependsOn.
%               report.filename is a cell array of the filenames that
%               depend on the toolbox. report.dependsOn is a cell array of
%               cell arrays each specifying the toolbox files upon which
%               the corresponding file depends. Example:
%               report.filename{42} = 'graphs/@graph/private/loadGraph'
%               report.dependsOn{42} = { 'stats/foo', 'stats/bar'}
%
% errors      - A structure listing any errors encountered with fields:
%               filename,errmsg,errid in the same format as report. 
%
%
% examples:
%
% report = deptoolbox('stats');
% report = deptoolbox('c:\mycode\',true)
% [report, errors] = deptoolbox('stats')
% [report, errors] = deptoolbox
%
% Note, dependencies are listed relative to the specified toolbox
% directory and filenames are listed relative to the present working
% directory. 
% PMTKneedsMatlab 
%%

% This file is from pmtk3.googlecode.com


if(nargin < 3)
    visualize = false;
end

currentDirectory = pwd; 
report = [];
errors = struct; errors.filename = {}; errors.errmsg = {}; errors.errid = {};
mfiles = findAllMfiles(currentDirectory);
if(nargin == 0) %Generate a report of all external dependencies. 
    toolboxroot = pwd;
    report = generateReport(mfiles,'all');
else
    if(nargin < 2),isroot = false; end
    [valid, toolboxroot] = checkToolbox(toolboxname,isroot);
    if(not(valid)),return,end
    report = generateReport(mfiles);
end


if(isempty(report.filename))
   fprintf('\n\n no dependencies found.\n\n'); 
else
   if(visualize)
        displayReport(report); 
        graphReport(report);
   end
end
if(numel(errors.filename) > 0)
    displayErrors(errors);
else
    fprintf('\n no errors detected.\n');
end

    function mfiles = findAllMfiles(directory)
    %Find all of the m-files in the specified directory and all of its
    %subdirectories. 
        info = dirinfo(directory);
        mfiles = cell(numel(vertcat(info.m),1));
        counter = 1;
        for i=1:numel(info)
            for j = 1: numel(info(i).m)
                mfiles{counter,1} = [info(i).path,filesep,cell2mat(info(i).m(j))];
                counter = counter + 1;
            end
        end
        
        function info = dirinfo(directory)
        %Recursively generate an array of structures holding information about each
        %directory/subdirectory beginning with, (and including) the initially specified
        %parent directory. 
            info = what(directory);
            flist = dir(directory);
            dlist =  {flist([flist.isdir]).name};
            for i=1:numel(dlist)
                dirname = dlist{i};
                if(~strcmp(dirname,'.') && ~strcmp(dirname,'..'))
                    info = [info, dirinfo([directory,'\',dirname])]; 
                end
            end
        end %end of dirinfo
    end %end of findAllMfiles

    function report = generateReport(mfiles,scope)
    %Build the dependency report
        report = struct; report.filename = {}; report.dependsOn = {};
        for m=1:numel(mfiles)
            if((nargin == 2) && strcmp(scope,'all'))
                dependencies = depScan(mfiles{m},true);
            else
                dependencies = depfunTB(mfiles{m});
            end
            dependencies = relativePath(dependencies);
            if(~isempty(dependencies))
                fname = relativePath(mfiles{m});
                report.filename = vertcat(report.filename,{fname});
                report.dependsOn = vertcat(report.dependsOn,{dependencies});
            end
        end
    end %end of generateReport


    function filelist = depfunTB(filename)
    %Like builtin depfun except it only returns dependencies on the
    %specified toolbox and is thus much faster. Based on exportToZip by
    %Malcolm Wood available in the Mathworks file exchange. Altered
    %significantly here.
        filelist = depScan(filename);
        toscan = filelist; 
        while numel(toscan)>0
            if(not(strncmpi(toscan{1},toolboxroot,numel(toolboxroot))))
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
        list = {};
        try
            [list, builtins, classes, prob_files, prob_sym,...
                eval_strings,called_from, java_classes]  = ...
                depfun(func,'-toponly','-quiet');
            list(1) = []; %func is always at the top of the list
            if(not(isempty(prob_files)))
                for i=1:numel(prob_files)
                    errors.filename = vertcat(errors.filename,{relativePath(prob_files(i).name)});
                    errors.errmsg = vertcat(errors.errmsg,{prob_files(i).errmsg});
                    errors.errid = vertcat(errors.errid,{prob_files(i).errid});
                end
            end
        catch ME
            errors.filename = vertcat(errors.filename,{relativePath(func)});
            errors.errmsg = vertcat(errors.errmsg,{ME.message});
            errors.errid = vertcat(errors.errid,{ME.identifier});
        end
        intoolbox = strncmpi(list,toolboxroot,numel(toolboxroot));
        if(invert)
            matlabpath = fullfile(matlabroot,'toolbox','matlab');
            matlab = strncmpi(list,matlabpath,numel(matlabpath));
            list = list(~matlab & ~intoolbox);
        else
            list = list(intoolbox);
        end
    end %end of depScan


    function [valid, toolboxroot] = checkToolbox(toolboxname,isroot)
    %Make sure the toolbox is properly specified and setup the toolboxroot.
        if(isroot)
            toolboxroot = toolboxname;
        else
            toolboxroot = fullfile(matlabroot,'toolbox',toolboxname);
        end
        valid = true;
        badsep = setdiff({'\','/'},filesep);
        if(not(isempty(strfind(toolboxroot,badsep{:}))))
            fprintf('\n'); display(['please use ',filesep,' in the path name, not ' badsep{:}]);
            fprintf('\n');
            valid = false; 
            return;
        end
        if(not(isdir(toolboxroot)) || (numel(dir(toolboxroot))==0))
            fprintf('\n'); display([toolboxname,' is empty or does not exist.']); 
            fprintf('\n'); 
            valid = false;
            return;
        end
    end %end of checkToolbox 



    function fname = relativePath(fname)
    %If the fname's path includes as a prefix either the current working
    %directory or the matlab toolbox directory, this part of the path is
    %removed.
        if(iscell(fname))
            for i=1:numel(fname)
                fname{i} = relpathHelper(fname{i});
            end
        else
            fname = relpathHelper(fname);
        end
        function fname = relpathHelper(fname)
            toolboxdir = fullfile(matlabroot,'toolbox');
            if(strncmp(pwd,fname,numel(pwd)))
                fname = fname(numel(pwd)+1:end);
            elseif(strncmp(toolboxdir,fname,numel(toolboxdir)))
                fname = fname(numel(toolboxdir)+1:end); 
            elseif(strncmp(toolboxroot,fname,numel(toolboxroot)))
                fname = fname(numel(toolboxroot)+1:end);
            end
        end %end of relpathHelper
    end% end of relativePath
   

function displayReport(report)
%Display the report in a table
    if(~exist('javaTable','file'))
        return;
    end
    
    nrows = numel(vertcat(report.dependsOn{:}))+numel(report.filename);
    data = cell(nrows,4);
    data(:) = {''};
    counter = 1;
    for i=1:numel(report.filename)
        [path,name,ext,ver] = fileparts(report.filename{i});
        data{counter,1} = path;
        data{counter,2} = [name,ext];
        dependsOn = report.dependsOn{i};
        for j=1:numel(dependsOn)
            [path,name,ext,ver] = fileparts(dependsOn{j});
            data{counter,3} = path;
            data{counter,4} = [name,ext];
            counter = counter + 1;
        end
        counter = counter + 1;
    end
    
    columns = {'Source Directory','Source File','External Directory','External File'};
    javaTable(data,columns,'External Dependency Report');
end

function displayErrors(errors)
%Display the errors in a table, (if any)

    data = [errors.filename,errors.errmsg,errors.errid];
    columnNames = {'Filename','Message','ID'};
    javaTable(data,columnNames,'Error Report');
end


function graphReport(report)
%Display a graph showing external dependencies.
    if(~exist('bioinfo','dir'))
        return;
    end
    
    r = report;
    map = struct;
    names = {};
    counter = 1;
    external = {};
    for f=1:numel(r.filename)
        [path,name,ext,ver] = fileparts(r.filename{f});
        name = genvarname(name);
        r.filename{f} = genvarname(name);
        if(~ismember(name,fieldnames(map)))
           map.(name) = counter;
           names(counter) = {name};
           counter = counter + 1;
        end
        dependsOn = r.dependsOn{f};
        for d=1:numel(dependsOn)
            [path,name,ext,ver] = fileparts(dependsOn{d});
            name = genvarname(name);
            dependsOn{d} = name;
            if(~ismember(name,fieldnames(map)))
               map.(name) = counter;
               external = [external,name];
               names(counter) = {name};
               counter = counter + 1;
            end
        end
        r.dependsOn{f} = dependsOn;
    end
    
    adjmat = zeros(numel(fieldnames(map)));
    for i=1:numel(r.filename)
        srcidx = map.(r.filename{i});
        dependsOn = r.dependsOn{i};
        for d=1:numel(dependsOn)
           dstidx = map.(dependsOn{d});
           
           adjmat(srcidx,dstidx) = 1; 
        end
    end
    [tf,loc] = ismember('graph',names);
    if(tf)
        names{loc} = 'graph*';          %biograph bugfix
    end
    bg = biograph(adjmat,names,'LayoutType','radial','EdgeType','straight');
    extcolor = [0 0.5 1];
    nodes = get(bg,'Nodes');
    for n=1:numel(nodes)
        if(ismember(nodes(n).ID,external))
           nodes(n).Color =  extcolor;
        end
        
    end
    view(bg);
    
    
   
end
    
    

end %end of file
