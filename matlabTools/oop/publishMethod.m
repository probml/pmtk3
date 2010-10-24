function publishMethod(mfile,methodName,evalCode)
% Publish a class method or a subfuncion of an mfile to html.
%
% INPUTS:
%
% mfile      - the name of the mfile containing the function/method without the .m
% methodName - the name of the method/function
% evalCode   - [true] | false  if true, the code is evaluated and the results also
%              published. The code must be executable as a stand alone script. 
%
%
% Example:
%
% publishMethod LogregDist demoVisualizePredictive
% 
% PMTKneedsMatlab 2008
%%

% This file is from pmtk3.googlecode.com

    
    endTag = '%!';  % Must occur at the end of the function/method to be published
   
%% error check    
    if(nargin < 2),error('Too few arguments');end
    if(strcmp(mfile(end-1:end),'.m')),mfile = mfile(1:end-2);end
    if(~exist([mfile,'.m'],'file'))
       fprintf('\nCould not find file %s.m\n',mfile);
       return;
    end
%% grab file contents    
    fid = fopen([mfile,'.m']);
    fulltext = textscan(fid,'%s','delimiter','\n','whitespace','');
    fclose(fid);
    fulltext = fulltext{:};
%% find method
    keylocations = cell2mat(cellfun(@(str)~isempty(str),strfind(fulltext,methodName),'UniformOutput',false));
    flocations   = cell2mat(cellfun(@(str)~isempty(str),strfind(fulltext,'function'),'UniformOutput',false));
    start = find(keylocations & flocations);
    if(isempty(start))
       fprintf('\nFound the file %s.m\nbut could not find the function\n%s\n',mfile,methodName);
       return;
    end
    start = start(1);
%% extract method contents
    methodtext = {};
    counter = 1;
    while(true)
        linetext = fulltext{start + counter};
        if(strfind(linetext,endTag)),break;end
        methodtext{counter} = linetext;                 %#ok
        counter = counter + 1;
        if(counter + start > numel(fulltext))
            fprintf('\nCould not find an end tag for method %s.\nAdd the comment %s just after the method''s end\nstatement as in end%s\n',methodName,endTag,endTag); 
            return;
        end
    end
    
    if(numel(methodtext) == 0)
        fprintf('Could not find method %s',methodName);
        return;
    end    
%% remove leading blanks (keep indentation)
    methodtext = methodtext';
    nblanks = min(cell2mat(cellfun(@(str)length(deblank(str))-length(strtrim(deblank(str))),methodtext(~isempty(methodtext)),'UniformOutput',false)));
    methodtext = cellfun(@(str)str(nblanks+1:end),methodtext,'UniformOutput',false);
%% write to a temporary file
    fid = fopen([methodName,'Published.m'],'w+');
    for i=1:numel(methodtext)
       fprintf(fid,'%s\n',methodtext{i}); 
    end
    fclose(fid);
%% publish to HTML
    if(nargin < 3)
        evalCode = true;
    end
    options.evalCode = evalCode;
    options.outputDir = fullfile(pwd,[mfile,'Examples'],methodName);
    options.format = 'html';
    
    publish([methodName,'Published.m'],options);
%% clean up and display     
    delete([methodName,'Published.m']);
    web(fullfile('file:///',pwd,[mfile,'Examples'],methodName,[methodName,'Published.html']));
    
    
end
