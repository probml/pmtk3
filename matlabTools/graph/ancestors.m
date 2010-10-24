function a = ancestors(adj_mat,i)
% Recursively find all ancestors of a a node, (parents, grandparents, ... etc)

% This file is from pmtk3.googlecode.com


a = [];
if isempty(parents(adj_mat,i))
    return;
else
    p = parents(adj_mat,i);
    for i=1:numel(p)
        a = [a,ancestors(adj_mat,p(i))];
    end
    a = [p,a];
end




end




