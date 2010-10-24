function deleteIdenticalShadowedCopies()
% Search through every m-file and delete exact char for char duplicates

% This file is from pmtk3.googlecode.com


m = mfiles(pmtk3Root());
for i=1:numel(m)
    w = which('-all',m{i});
    if(numel(w) == 2 && isequal(getText(w{1}), getText(w{2})))
        fprintf('removing...%s\n',w{2});
        %delete(w{2}); % uncomment me to delete
    end
end
end
