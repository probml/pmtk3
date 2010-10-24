function m = methodInfo(className,methodName, full)
% Return a struct storing detailed info about a method. 
% If the method does not exist, [] is returned.
%
% Example:
%
% m = methodInfo('MvnDist','infer')
%
%%
% m.Name                    - name of the method
% m.isPublic                - true iff the method is public
% m.isAbstract              - true iff the method is abstract
% m.isLocal                 - true iff the method is local
% m.isStatic                - true iff the method is static
% m.isHidden                - true iff the method is hidden
% m.isSealed                - true iff the method is sealed
% m.isConstructor           - true iff the method is the class constructor
% m.isNewToBranch           - true iff this is the first occurrence of this method in any branch of the inheritence tree to which this class belongs.
% m.isUnfinished            - true iff calling the method throws a PMTK:notYetFinishedError
% m.methodObject            - a Matlab method object for this method storing additional info

% This file is from pmtk3.googlecode.com


% only calculated if full=true

% m.methodHeader            - the first line of the method if implemented, i.e. 'function outputs = methodName(inputs)
% m.methodComment           - a method comment, if any
% m.methodBody              - the code body of the method
% m.methodText              - the whole method text
% m.tags                    - any tags found in the method text
% m.tagVals                 - the 'values' of any tags found - i.e. the text following them.
% PMTKneedsMatlab 2008


if nargin < 3, full = false; end

m = [];
if ~isclassdef(className),error('Could not find class %s\n',className);end
classMethods = meta.class.fromName(className).Methods;
mobj = classMethods(findString(methodName,cellfuncell(@(c)c.Name,classMethods)));
if isempty(mobj), return; end

mobj = mobj{:};

m.Name       = methodName;
m.isPublic   = strcmpi(mobj.Access,'public');
m.isProtected = strcmpi(mobj.Access,'protected');
m.isPrivate   = strcmpi(mobj.Access,'private');
m.isAbstract = mobj.Abstract;
m.isLocal    = strcmpi(className,mobj.DefiningClass.Name);
m.isStatic   = mobj.Static;
m.isHidden   = mobj.Hidden;
m.isSealed   = mobj.Sealed;
m.isConstructor = strcmp(className,methodName);
m.isNewToBranch = ~ismember(methodName,superMethods(className));







m.methodObject = mobj;
m.methodHeader = '';
m.methodComment = '';
m.methodBody = '';
m.methodText = '';
m.tags = {};
m.tagVals = {};
m.isUnfinished = false;

try
    clsText = filterCell(getText(which(className)),@(c)~isempty(c));
    start = firstTrue(cellfun(@(c)~isempty(c),strfind(clsText,'function')) & cellfun(@(c)~isempty(c),strfind(clsText,methodName)));
    if isempty(start), return; end
    m.methodHeader = strtrim(clsText{start});
    codeStart = firstTrue(cellfun(@(c)~strncmp(strtrim(c),'%',1),clsText(start+1:end)))+ start;
    if codeStart > start+1
        m.methodComment = cellfuncell(@(c)strtrim(c),clsText(start+1:codeStart-1));
    end
    indentPattern = cellfun(@(c)firstTrue(~isstrprop(c,'wspace')),clsText(start:end));
    methodEnd = firstTrue(cellfun(@(c)~isempty(c),strfind(clsText(start:end),'end')) & indentPattern == indentPattern(1)) + start-1;
    
    m.methodBody = clsText(codeStart:methodEnd);
    m.methodText = clsText(start:methodEnd);
    tags = filterCell(m.methodComment,@(c)ismember('#',c));
    for j=1:numel(tags)
        [m.tags{j},m.tagVals{j}] = strtok(tags{j});
    end
end
try
    m.isUnfinished = any(cellfun(@(c)~isempty(c),(strfind(m.methodBody,'notYetImplemented'))));
end




m.argNames = {};

try
    ndx = firstTrue(cellfun(@(c)~isempty(c),cellwrap(strfind(m.methodBody,'processArgs'))));
    if ndx
        txt = catString(m.methodBody(ndx:end),'');
        endline = firstTrue(txt == ';'); if ~endline, endline = length(txt); end
        txt = tokenize(txt(1:endline),',...''');
        m.argNames = txt(cellfun(@(c)~isempty(c) && (isprefix('-',c) || isprefix('+-',c) || isprefix('*-',c) || isprefix('*+-',c) || isprefix('+*-',c)) ,txt));
    end
end
m.outputs = {};

try
    if any(m.methodHeader == '=')
        outputStr = subc(tokenize(strtok(m.methodHeader,'='),' '),2);
        m.outputs = removeEmpty(tokenize(outputStr,'[,]'));
    end
end
m.inputs = {};

try
    m.inputs = tokenize(subc(tokenize(subc(tokenize(m.methodHeader, '='),2),'('),2),',)');
end
m.inputStr = {};

try
    if ismember('varargin',m.inputs)
        m.inputStr = [catString(m.inputs(1:end-1),','),', ',catString(m.argNames)];
    else
        m.inputStr = catString(m.inputs);
    end
    if m.inputStr(1) == ',',m.inputStr = m.inputStr(2:end);end
end




    function meths = superMethods(clsName)
        % Return every method defined by every super class of clsName, recursively
        % accumulated.
        if isempty(clsName)
            meths = {};
        else
            supers = cellfuncell(@(c)c.Name,meta.class.fromName(clsName).SuperClasses);
            meths = {};
            for i=1:numel(supers)
                sn = supers{i};
                meths = unique([meths;colvec(cellfuncell(@(c)c.Name,meta.class.fromName(sn).Methods));superMethods(sn)]);
            end
        end
    end


end
