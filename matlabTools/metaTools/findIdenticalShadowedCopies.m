function f = findIdenticalShadowedCopies()
% Searches through every m-file and finds exact duplicates

% This file is from pmtk3.googlecode.com

m = mfiles(pmtk3Root());
f = {};
for i=1:numel(m)
    w = which('-all',m{i});
    if(numel(w) == 2 && isequal(getText(w{1}),getText(w{2})))
        f = [f, w{2}]; %#ok
    end
    
end
f = f';

end
