function support = getSupport(labels)
% Return the support of the labels
%
%
% examples
%
% getSupport([1 1 2 3 3 3 2 3 3 2])
% ans =
%     1
%     2
%     3
%
%
% getSupport({'alpha', 'alpha', 'beta', 'alpha', 'gamma'})
%ans = 
%    'alpha'
%    'beta'
%    'gamma'

    [junk, support] = canonizeLabels(labels); 
end