function out = linregPostSummary(model, varargin)
% Return summaries of the posterior distribution of the regression weights
% You must call linregFitBayes first
% out is a structure containing
%  what % posterior mean
%  stderr % posterior standard deviation
%  credint(i,1:2) % 95% credible interval
%
% If you set display=true, it
% prints the summary (as a latex table) to the screen

% This file is from pmtk3.googlecode.com

[doDisplay, useLatex] = process_options(varargin, ...
  'displaySummary', true, 'latex', false);

% Extract posterior parameters
wn = model.wN; Vn = model.VN;

what = wn;
alpha = 0.95;
if isfield(model, 'aN')
  % p(w|D) = T( wn, (bn/an) Vn, 2an) if sigma integrated out
  an = model.aN; bn = model.bN;
  dof = 2*an;
  C = (bn/an)*Vn;
  stderr = sqrt(diag(C));
  tc = tinvPMTK(1-(1-alpha)/2, dof); % quantiles of a T
  credint = [what-tc*stderr what+tc*stderr];
else
  % p(w|D) = N( wn, Vn) if sigma is fixed
  C = Vn;
  stderr = sqrt(diag(C));
  tc = norminv(1-(1-alpha)/2); % quantiles of a normal
  credint = [what-tc*stderr what+tc*stderr];
end

 D = length(wn);
 for i=1:D
   L = credint(i,1); U = credint(i,2);
   sig(i) = (L<0 && U<0) || (L>0 && U>0);
 end
 
if doDisplay
 
  
  if useLatex
    fprintf('coeff & mean & stddev & 95pc CI & sig\n');
  else
    fprintf('%-5s %-10s %-10s %-20s %-5s \n', 'coeff', 'mean', 'stddev', '95pc CI', 'sig');
  end
  for i=1:D
    if model.preproc.addOnes, j=i-1; else j=i; end
    %L = credint(i,1); U = credint(i,2);
    %sig = (L<0 && U<0) || (L>0 && U>0);
    if sig(i), sigStr = '*'; else sigStr = ''; end
    if useLatex
      fprintf('w%d & %3.3f & %3.5f & [%3.3f, %3.3f] & %s \\\\\n', ...
        j, what(i), stderr(i), credint(i,1), credint(i,2), sigStr)
    else
      fprintf('%5s %8.3f  %8.5f  [%8.3f, %8.3f] %5s \n', ...
        sprintf('w%d',j), what(i), stderr(i), credint(i,1), credint(i,2), sigStr)
    end
  end
  fprintf('\n');
end

out = structure(what, stderr, credint, sig);

end
