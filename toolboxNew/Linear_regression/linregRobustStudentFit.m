function model = linregRobustStudentFit(X, y, dof, sigma2, includeOffset) 

if nargin < 3, dof = []; end
if nargin < 4, sigma2 = []; end
if nargin < 5, includeOffset = true; end

if dof==0, dof = []; end

if isempty(sigma2) && isempty(dof)
  % estimate everything
  model = linregRobustStudentFitEm(X, y, [], includeOffset);
  %model = linregRobustStudentFitConstr(X, y, [], [], includeOffset);
  %model = linregRobustStudentFitUnconstr(X, y, includeOffset);
elseif ~isempty(dof) && isempty(sigma2)
  % fixed dof
  model = linregRobustStudentFitEm(X, y, dof, includeOffset);
  %model = linregRobustStudentFitConstr(X, y, dof, [], includeOffset);
elseif  ~isempty(dof) && ~isempty(sigma2)
  % only estimate w - not recommended
  model = linregRobustStudentFitConstr(X, y, dof, sigma2, includeOffset);
else
  error('cannot handle fixed sigma2 but variable dof')
end

end