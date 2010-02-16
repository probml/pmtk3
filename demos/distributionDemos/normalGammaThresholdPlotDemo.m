function normalGammaThresholdPlotDemo()

%#author Francois Caron

%z=-10:.1:10;
z=-10:0.5:10;
x=-10.005:.05:10;
for k=1:length(z)
  % laplace
  c=.001;
  [temp outLap(k)]=min(.5*(z(k)-x).^2+c*abs(x));
  
  % NG
  deltas = [0.01 0.75 1 2];
  for i=1:length(deltas)
    delta = deltas(i);
    [temp outNG{i}(k)]=min(.5*(z(k)-x).^2+pen_normalgamma(x, delta, 1));
  end
  
  % normal Jeffreys
  [temp outNJ(k)]=min(.5*(z(k)-x).^2+log(abs(x)));
  
  % normal inverse Gaussian
  deltas = [0.01 0.75 1 2];
  for i=1:length(deltas)
    delta = deltas(i);
    [temp outNIG{i}(k)]=min(.5*(z(k)-x).^2+pen_NIG(x, delta, 1));
  end
  
  % normal exponential Gaussian
  as = [0.5 0.5 0.5 5];
  bs = [1 0.1 0.05 0.1];
  for i=1:length(as)
    [temp outNEG{i}(k)]=min(.5*(z(k)-x).^2+pen_NEG(x, as(i), bs(i)));
  end
end

[styles, colors, symbols] =  plotColors();


figure;
plot(z,x(outNJ),styles{1}, 'linewidth', 2);
hold on
plot(z,z,'r:', 'linewidth', 3)
title('normalJeffreys')
printPmtkFigure('NJthreshold')

figure
hold on
for i=1:length(deltas)
  plot(z,x(outNG{i}),styles{i}, 'linewidth', 2);
  str{i} = sprintf('%s = %5.3f, c=1', '\delta', deltas(i));
end
legend(str, 'location', 'southeast')
plot(z,z,'r:', 'linewidth', 3)
title('normalGamma')
printPmtkFigure('NGthreshold')

figure
hold on
for i=1:length(deltas)
  plot(z,x(outNIG{i}),styles{i}, 'linewidth', 2);
  str{i} = sprintf('%s = %5.3f, c=1', '\delta', deltas(i));
end
legend(str, 'location', 'southeast')
plot(z,z,'r:', 'linewidth', 3)
title('normalInvGauss')
printPmtkFigure('NIGthreshold')

figure
hold on
for i=1:length(outNEG)
  plot(z,x(outNEG{i}),styles{i}, 'linewidth', 2);
  str{i} = sprintf('a = %5.3f, b=%5.3f', as(i), bs(i));
end
legend(str, 'location', 'southeast')
plot(z,z,'r:', 'linewidth', 3)
title('normalExpGauss')
printPmtkFigure('NEGthreshold')


end


function out=pen_normalgamma(w, delta, c)
gamma = sqrt(2*c);
warning off
out=(.5-delta)*log(abs(w))-log(besselk(delta-.5,gamma*abs(w)));
warning on
end

function out = pen_NIG(w, delta, gamma)
tmp = sqrt(delta^2 + w.^2);
out = log(tmp)-log(besselk(1,gamma*tmp));
end

function out=pen_NEG(w,lambda,c)
% c = gamma^2/2
gamma = sqrt(2*c);
warning off
%out=-w.^2/(4*gamma^2)-log(mpbdv(-2*(lambda+1/2),abs(w)./gamma));
for k=1:length(w)
  out(k)=-w(k)^2/(4*gamma^2)-log(mpbdv(-2*(lambda+1/2),abs(w(k))/gamma));
end
warning on
end
