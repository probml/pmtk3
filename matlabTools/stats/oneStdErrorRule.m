function idx_opt = oneStdErrorRule(res_mean, res_std, dof)
% We pick the model whose error is within one standard error of the lowest
% We assume models are ordered from least complex to most complex
% If not, pass in the dof field to figure out the right order

% This file is from pmtk3.googlecode.com


n = length(res_mean);
if nargin < 3, dof = 1:n; end

[sortedDof, perm] = sort(dof); % smallest dof first
if ~isequal(dof, sortedDof)
    %fprintf('sorting so simplest model comes first\n')
    res_mean = res_mean(perm);
    res_std = res_std(perm);
end

[res_min idx_opt] = min(res_mean);
limit = res_min + res_std(idx_opt);
idx_opt2 = find(res_mean < limit, 1);
if ~isempty(idx_opt2)
    idx_opt = idx_opt2;
end
idx_opt = perm(idx_opt);

end
