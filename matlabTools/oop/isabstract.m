function tf = isabstract(className)
% Return true iff the class is abstract    
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

    
    if hasTag(which(className),'%PMTKabstract')
        tf = true; return;
    end

    tf       = false; 
    metaInfo = meta.class.fromName(className);
    if(numel(metaInfo) == 0)
        fprintf('%s is not a class.\n',className);
        return;
    end
    
    methods = metaInfo.Methods;
    props   = metaInfo.Properties;
    for i=1:numel(methods)
       if methods{i}.Abstract
           tf = true;
           return;
       end
    end
    
    for i=1:numel(props)
       if props{i}.Abstract
           tf = true;
           return;
       end
    end
end
