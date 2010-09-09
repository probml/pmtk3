function p = noncentraltpdf(x, v, a, b)
% Noncentral T PDF
% location a, scale b, dof v
% See The Bayesian Two-Sample t Test , M. Gönen and W. Johnson and Y. Lu and P. Westfall,
% The American Statistician, 59(3), 252:257, 2005
% PMTKneedsStatsToolbox nctpdf

% This file is from pmtk3.googlecode.com

bb = sqrt(b);
p = nctpdf(x/bb, v, a/bb)/bb;
end
