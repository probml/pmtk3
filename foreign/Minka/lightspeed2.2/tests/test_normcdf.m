x = linspace(-20,2,100);
w = exp(-0.5*x.^2 -0.5*log(2*pi));
f = exp(-normcdfln(x));
g = 1./normcdf(x);
%g = exp((log(1+exp(0.88+x))./1.5).^2);
%g = exp(0.5*log(2*pi) +0.5*x.^2 + log(x));
plot(x, f.*w, x, g.*w)
legend('exp(-normcdfln)','1/normcdf');

if 0
  true = -27.3843074988;
  [abs(log(normcdf(-7))-true) abs(normcdfln(-7)-true)]
end

if 0
  %matnet
  %imports('c:/Documents and Settings/minka/Depots/Infer/Core/bin/Debug/Core.dll')
  h = g;
  for i = 1:length(x)
    h(i) = 1./cl.MMath.NormalCdf(x(i));
  end
  %h = 0.5*(-x + sqrt(x.*x + 8/pi));
  plot(x, f.*w, x, g.*w, x, h.*w)
  legend('exp(-normcdfln)','1/normcdf', '1/normcdf2');
  
  plot(x, f.*w - h.*w)
end

% evalf(subs(t=1e-4,subs(x=2*(1-t)/t,erfc(x)*exp(x*x))),100);

if 0
% test approximations
a = exp(sqrt(2/pi));
b = 1/log(2/pi*a);
g = log(a-1 + exp(x.*exp(1./(x.^2 + b))));
g = log(a-1 + exp(x));
plot(x, f, x, g)
plot(x, log(exp(f)+1-a)./x)
plot(x, 1./log(log(exp(f)+1-a)./x))
end

% read `/u/tpminka/src/maple/gauss_cdf`; 
% f := 1/sqrt(2*Pi)*exp(-1/2*x^2)/gauss_cdf(-x);
% g := exp(sqrt(2/Pi))-1+exp(x);
% plot(f, x=0..50);
% h := log(exp(f*sqrt(Pi/2)-1)+1);
% h := log(exp(f - sqrt(2/Pi))+1);
% h := 1/log(log(exp(f) +1-exp(sqrt(2/Pi)))/x);
% asympt(h,x);
