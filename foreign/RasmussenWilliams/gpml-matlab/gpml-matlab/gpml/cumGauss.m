function [out1, out2, out3, out4] = cumGauss(y, f, var)

% cumGauss - Cumulative Gaussian likelihood function. The expression for the 
% likelihood is cumGauss(t) = normcdf(t) = (1+erf(t/sqrt(2)))/2.
%
% Three modes are provided, for computing likelihoods, derivatives and moments
% respectively, see likelihoods.m for the details. In general, care is taken
% to avoid numerical issues when the arguments are extreme. The
% moments \int f^k cumGauss(y,f) N(f|mu,var) df are calculated analytically.
%
% Copyright (c) 2007 Carl Edward Rasmussen and Hannes Nickisch, 2007-03-29.

if nargin>1, y=sign(y); end                         % allow only +/- 1 as values

if nargin == 2                                     % (log) likelihood evaluation
     
  if numel(y)>0, yf = y.*f; else yf = f; end     % product of latents and labels
     
  out1 = (1+erf(yf/sqrt(2)))/2;                                     % likelihood
  if nargout>1   
    out2 = zeros(size(f));
    b =  0.158482605320942;           % quadratic asymptotics approximated at -6
    c = -1.785873318175113;    
    ok = yf>-6;                            % normal evaluation for larger values
    out2( ok) = log(out1(ok)); 
    out2(~ok) = -yf(~ok).^2/2 + b*yf(~ok) + c;                  % log of sigmoid
 end

elseif nargin == 3 
    
  if strcmp(var,'deriv')                                % derivatives of the log

    if numel(y)==0, y=1; end
    yf = y.*f;                                   % product of latents and labels
    [p,lp] = cumGauss(y,f);
    out1   = sum(lp);

    if nargout>1                             % dlp, derivative of log likelihood
      
      n_p = zeros(size(f));   % safely compute Gaussian over cumulative Gaussian
      ok = yf>-5;                     % normal evaluation for large values of yf
      n_p(ok) = (exp(-yf(ok).^2/2)/sqrt(2*pi))./p(ok); 

      bd = yf<-6;                                 % tight upper bound evaluation
      n_p(bd) = sqrt(yf(bd).^2/4+1)-yf(bd)/2;

      interp = ~ok & ~bd;            % linearly interpolate between both of them
      tmp = yf(interp);
      lam = -5-yf(interp);
      n_p(interp) = (1-lam).*(exp(-tmp.^2/2)/sqrt(2*pi))./p(interp) + ...
                                                lam .*(sqrt(tmp.^2/4+1)-tmp/2);

      out2 = y.*n_p;                         % dlp, derivative of log likelihood
      if nargout>2                      % d2lp, 2nd derivative of log likelihood
        out3 = -n_p.^2 - yf.*n_p;
        if nargout>3                    % d3lp, 3rd derivative of log likelihood
          out4 = 2*y.*n_p.^3 +3*f.*n_p.^2 +y.*(f.^2-1).*n_p; 
        end
      end
    end
   
  else                                                         % compute moments

    mu = f;                             % 2nd argument is the mean of a Gaussian
    z = mu./sqrt(1+var);
    if numel(y)>0, z=z.*y; end
    out1 = cumGauss([],z);                                   % zeroth raw moment
        
    [dummy,n_p] = cumGauss([],z,'deriv');    % Gaussian over cumulative Gaussian

    if nargout>1
      if numel(y)==0, y=1; end
      out2 = mu + y.*var.*n_p./sqrt(1+var);                     % 1st raw moment
      if nargout>2
        out3 = 2*mu.*out2 -mu.^2 +var -z.*var.^2.*n_p./(1+var); % 2nd raw moment
        out3 = out3.*out1;
      end
      out2 = out2.*out1;
    end

  end

else
  error('No valid input provided.')    
end
