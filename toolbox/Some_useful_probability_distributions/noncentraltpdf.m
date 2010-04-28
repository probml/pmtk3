function p = noncentraltpdf(x, v, a, b)
% location a, scale b, dof v
% See The Bayesian Two-Sample t Test , M. Gönen and W. Johnson and Y. Lu and P. Westfall,
% The American Statistician, 59(3), 252:257, 2005

bb = sqrt(b);
p = nctpdf(x/bb, v, a/bb)/bb;
