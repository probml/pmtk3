function addClass(varargin)
% Create a class template from its possibly abstract superclasses
%
% INPUTS: 
%
% '-className'
% '-superClasses'
% '-objName'
% '-allowOverwrite
% '-saveDir'

% This file is from pmtk3.googlecode.com




%
% EXAMPLE:
%
% createClass('MvnDist',fullfile(PMTKroot(),'models'),'MultivarDist','model')
% PMTKneedsMatlab 2008

    [className,superClasses,objName,allowOverwrite,saveDir] = process_options(varargin,'*className','','superClasses',{},'objName','model','allowOverwrite',true,'saveDir',fullfile(PMTKroot(),'models'));
    if exist(fullfile(saveDir,className),'file') && ~allowOverwrite
        error('%s already exists',className);
    end
    
    
    abstractMethods = {};
    abstractProperties = {};
    if ~isempty(superClasses)
        if ischar(superClasses), superClasses = {superClasses}; end
        
        classHeader = ['classdef ',className,' < ',catString(superClasses,' & ')];
        for i=1:numel(superClasses)
            m = meta.class.fromName(superClasses{i});
            if isempty(m), error('no superclass %s exists',superClasses{i}); end
            abstractMethods = unique([abstractMethods;colvec(cellfuncell(@(i)i.Name,filterCell(m.Methods,(@(c)c.Abstract))))]);
            abstractProperties = unique([abstractProperties;colvec(cellfuncell(@(i)i.Name,filterCell(m.Properties,@(c)c.Abstract)))]);
        end
        
        for i=1:numel(superClasses)
           m = meta.class.fromName(superClasses{i});
           abstractMethods = setdiff(abstractMethods,cellfuncell(@(i)i.Name,filterCell(m.Methods,(@(c)~c.Abstract))));
           abstractProperties = setdiff(abstractProperties,cellfuncell(@(i)i.Name,filterCell(m.Properties,(@(c)~c.Abstract)))); 
            
        end
        
        
    else
        classHeader = ['classdef ',className];
    end
    
    
    txt = {classHeader
        sprintf('%s\n','%#NotYetImplemented');
        sprintf('\n\tproperties\n')
        };
    
    for i=1:numel(abstractProperties)
        txt = [txt; sprintf('\t\t%s;',abstractProperties{i})];              %#ok
    end
    txt = [txt;
        sprintf('\n\tend\n\n');
        sprintf('\tmethods\n');
        sprintf('\t\tfunction %s = %s(varargin)',objName,className);
        sprintf('\t\t%%');
        sprintf('\t\tend\n');
        ];
    for i=1:numel(abstractMethods)
        txt = [txt;                                                         %#ok
            sprintf('\n\t\tfunction %s(%s,varargin)',abstractMethods{i},objName);
            sprintf('\t\t%%');
            sprintf('\t\t\tnotYetImplemented(''%s.%s()'');',className,abstractMethods{i});
            sprintf('\t\tend\n');
            ];
    end
    txt = [txt;
           sprintf('\n\tend\n');
           sprintf('\nend\n');
           ];
    
    filename = fullfile(saveDir,[className,'.m']);
    writeText(txt,filename);
    fprintf('Class %s created\n',className);
    
end
