function [y, initSupport] = setSupport(labels, newSupport, initSupport)
% Transform the support the labels from one space to another, i.e.
% from say [0, 1] to [-1 1] or {'setosa', 'versicolor', virginica'} to
% 1:3. 
%
% This is a generalization of canonizeLabels to arbitary spaces. 
% 
% If the input labels do not include at least one example from every
% class, you must also specify initSupport. 
%
% examples:
%
% setSupport([1 2 1 1 1 2 1 2 2 2 2 1], [-1, 1])
% ans =
%    -1     1    -1    -1    -1     1    -1     1     1     1     1    -1
%
%
% setSupport([1 2 3 3 2], {'yes', 'no', 'maybe'})
%ans = 
%   'yes'    'no'    'maybe'    'maybe'    'no'
%

    

    if nargin > 2, opt = {initSupport}; else opt={}; end
    [yC, initSupport] = canonizeLabels(labels, opt{:});
    y = reshape(newSupport(yC), size(labels));
end