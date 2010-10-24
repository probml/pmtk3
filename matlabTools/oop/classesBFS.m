function [classes,adjmat] = classesBFS(varargin)
% Return a list of classes in breadth first search order    
% Same inputs as getClasses    
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com

   
    
    classes = getClasses(varargin{:});
    if(isempty(classes)), fprintf('\nNo classes found in this directory.\n'); return; end
    classMap = enumerate(classes);
    adjmat = false(numel(classes));
    for c=1:numel(classes)
        supers = cellfuncell(@(n)n.Name,meta.class.fromName(classes{c}).SuperClasses);
        for s=1:numel(supers)
            if ismember(supers{s},classes), adjmat(classMap.(supers{s}),classMap.(classes{c})) = true;  end
        end
    end
    
    perm = topological_sort(adjmat);
    classes = classes(perm);
    adjmat = adjmat(perm,:);
    adjmat = adjmat(:,perm);
    
    
    
end
