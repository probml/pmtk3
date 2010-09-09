function out = logregPostSummary(model, varargin)
% Return summaries of the posterior distribution of the regression weights
% You must call logregFitBayes first
% out is a structure containing
%  what % posterior mean
%  stderr % posterior standard deviation
%  credint(i,1:2) % 95% credible interval
%
% If you set display=true, it
% prints the summary (as a latex table) to the screen

% This file is from pmtk3.googlecode.com

[doDisplay] = process_options(varargin, ...
  'displaySummary', true);

% Extract posterior parameters from Laplace approximation
wn = model.wN; Vn = model.VN;

what = wn;
alpha = 0.95;
% p(w|D) = N( wn, Vn) if sigma is fixed
C = Vn;
stderr = sqrt(diag(C));
tc = norminv(1-(1-alpha)/2); % quantiles of a normal
credint = [what-tc*stderr what+tc*stderr];

if doDisplay
  D = length(wn);

  fprintf('coeff & mean & stddev & 95pc CI & sig\n');
  for i=1:D
    if model.preproc.addOnes, j=i-1; else j=i; end
    L = credint(i,1); U = credint(i,2);
    sig = (L<0 && U<0) || (L>0 && U>0);
    if sig, sigStr = '*'; else sigStr = ''; end
    fprintf('w%d & %3.3f & %3.5f & [%3.3f, %3.3f] & %s \\\\\n', ...
      j, what(i), stderr(i), credint(i,1), credint(i,2), sigStr)
  end
  fprintf('\n');
  
  if 0
  if model.preproc.addOnes, coeff = 0:(D-1); else coeff=1:D; end
  T = [coeff(:) what(:) stderr(:) credint(:,1) credint(:,2)];
  latextable(T, 'Horiz', {'coeff', 'mean', 'stderr', 'lower', 'upper'}, ...
    'Hline', 1, 'format', '%5.3f')
  end
end

out = structure(what, stderr, credint);

end
