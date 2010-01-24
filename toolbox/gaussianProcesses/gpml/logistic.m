function [out1, out2, out3, out4] = logistic(y, f, var)

% logistic - logistic likelihood function. The expression for the likelihood is
% logistic(t) = 1./(1+exp(-t)).
%
% Three modes are provided, for computing likelihoods, derivatives and moments
% respectively, see likelihoods.m for the details. In general, care is taken
% to avoid numerical issues when the arguments are extreme. The moments
% \int f^k cumGauss(y,f) N(f|mu,var) df are calculated using an approximation
% to the cumulative Gaussian based on a mixture of 5 cumulative Gaussian
% functions (or alternatively using Gauss-Hermite quadrature, which may be less
% accurate).
%
% Copyright (c) 2007 Carl Edward Rasmussen and Hannes Nickisch, 2007-07-25.

if nargin>1, y=sign(y); end                         % allow only +/- 1 as values

if nargin == 2                                     % (log) likelihood evaluation
    
  if numel(y)>0, yf = y.*f; else yf = f; end     % product of latents and labels

  out1 = 1./(1+exp(-yf));                                           % likelihood
  if nargout>1
    out2 = yf;
    ok = -35<yf;
    out2(ok) = -log(1+exp(-yf(ok)));                         % log of likelihood
  end

elseif nargin == 3 

  if strcmp(var,'deriv')                         % derivatives of log likelihood

    if numel(y)==0, y=1; end
    yf = y.*f;                                   % product of latents and labels
     
    s    = -yf; 
    ps   = max(0,s); 
    out1 = -sum(ps+log(exp(-ps)+exp(s-ps)));          % lp = -sum(log(1+exp(s)))
    if nargout>1 % dlp - first derivatives
      s    = min(0,f); 
      p    = exp(s)./(exp(s)+exp(s-f));                     % p = 1./(1+exp(-f))
      out2 = (y+1)/2-p;                      % dlp, derivative of log likelihood
      if nargout>2                      % d2lp, 2nd derivative of log likelihood
        out3 = -exp(2*s-f)./(exp(s)+exp(s-f)).^2;
        if nargout>3                    % d3lp, 3rd derivative of log likelihood
          out4 = 2*out3.*(0.5-p);
        end
      end
    end

  else                                                         % compute moments
        
    mu = f;                             % 2nd argument is the mean of a Gaussian
    if numel(y)==0, y=ones(size(mu)); end                 % if empty, assume y=1
    
    % Two methods of integration are possible; the latter is more accurate
    % [out1,out2,out3] = gauherint(y, mu, var);
    [out1,out2,out3] = erfint(y, mu, var);
    
  end

else
  error('No valid input provided.')    
end


% The gauherint function approximates "\int t^k logistic(y t) N(t|mu,var)dt" by
% means of Gaussian Hermite Quadrature. A call to gauher.m is made.

function [m0,m1,m2] = gauherint(y, mu, var)

N = 20; [f,w] = gauher(N);                     % 20 yields precalculated weights
sz = size(mu);

f0 = sqrt(var(:))*f'+repmat(mu(:),[1,N]);                   % center values of f
sig = logistic( repmat(y(:),[1,N]), f0 );      % calculate the likelihood values
        
m0 = reshape(sig*w, sz);                                         % zeroth moment
if nargout>1                                                      % first moment
  m1 = reshape(f0.*sig*w, sz);
  if nargout>2, m2 = reshape(f0.*f0.*sig*w, sz); end             % second moment
end


% The erfint function approximates "\int t^k logistic(y t) N(t|mu,s2) dt" by 
% setting:
%         logistic(t) \approx 1/2 + \sum_{i=1}^5 (c_i/2) erf(lambda_i t)
% The integrals \int t^k erf(t) N(t|mu,s2) dt can be done analytically.
%
% The inputs y, mu and var have to be column vectors of equal lengths.

function [m0,m1,m2] = erfint(y, mu, s2)

l = [0.44 0.41 0.40 0.39 0.36]; % approximation coefficients lambda_i

c = [1.146480988574439e+02; -1.508871030070582e+03; 2.676085036831241e+03;  
    -1.356294962039222e+03;  7.543285642111850e+01                        ];
    
S2 = 2*s2.*(y.^2)*(l.^2) + 1;                                    % zeroth moment
S  = sqrt( S2 );
Z  = mu.*y*l./S;
M0 = erf(Z);
m0 = ( 1 + M0*c )/2;
    
if nargout>1                                                      % first moment
  NormZ = exp(-Z.^2)/sqrt(2*pi);
  M0mu = M0.*repmat(mu,[1,5]);
  M1 = (2*sqrt(2)*y.*s2)*l.*NormZ./S + M0mu;
  m1 = ( mu + M1*c )/2;
        
  if nargout>2                                                   % second moment
    M2 =   repmat(2*mu,[1,5]).*(1+s2.*y.^2*(l.^2)).*(M1-M0mu)./S2 ...
         + repmat(s2+mu.^2,[1,5]).*M0;
    m2 = ( mu.^2 + s2 + M2*c )/2;
  end
end


