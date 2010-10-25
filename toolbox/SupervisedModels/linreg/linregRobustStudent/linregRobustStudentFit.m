function model = linregRobustStudentFit(X, y, dof, sigma2)
%% Fit linear regression with Student noise model

% This file is from pmtk3.googlecode.com

if nargin < 3, dof = []; end
if nargin < 4, sigma2 = []; end


if dof==0, dof = []; end

if isempty(sigma2) && isempty(dof)
% estimate everything
    model = linregRobustStudentFitEm(X, y, []);
elseif ~isempty(dof) && isempty(sigma2)
% fixed dof
    model = linregRobustStudentFitEm(X, y, dof);
elseif  ~isempty(dof) && ~isempty(sigma2)
% only estimate w - not recommended
    model = linregRobustStudentFitConstr(X, y, dof, sigma2);
else
    error('cannot handle fixed sigma2 but variable dof')
end

end
