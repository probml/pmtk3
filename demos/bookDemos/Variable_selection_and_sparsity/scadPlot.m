%% LLA and LQA approximation - fig 1 of Zou & Li 2008
%
%%

% This file is from pmtk3.googlecode.com

function scadPlot()

z = -10:0.01:10;
a = 3.7; lambda = 2;

if 0
% Reproduce fig 1c of Fan & Li 2001
p = penalty(z, a, lambda);
figure;
plot(z, p, 'k-', 'linewidth', 3);
title(sprintf('scad penalty rule, %s=%5.3f, a=%5.3f', '\lambda', lambda, a))
printPmtkFigure('scadPenalty')
end


p = penalty(z, a, lambda);
figure; hold on
plot(z, p, 'k-', 'linewidth', 3);
pl = LLA(z, a, lambda, 4);
plot(z, pl, 'r--', 'linewidth', 3);
pq = LQA(z, a, lambda, 4);
plot(z, pq, 'b:', 'linewidth', 3);
title(sprintf('scad penalty rule, %s=%5.3f, a=%5.3f', '\lambda', lambda, a))
legend('SCAD', 'LLA', 'LQA')
printPmtkFigure('scadLLA')

if 0
% Reproduce fig 2c of Fan & Li 2001
z=-10:0.01:10;
theta = estimator(z, a, lambda);
figure;
plot(z, theta, 'k-', 'linewidth', 3);
hold on
plot(z, z, ':', 'linewidth', 2);
title(sprintf('scad thresholding rule, %s=%5.3f, a=%5.3f','\lambda', lambda, a))
printPmtkFigure('scadThreshold')
end

end

function th = estimator(z, a, lambda)
% equation 2.8 of their paper
th = zeros(size(z));
ndx = abs(z) <= 2*lambda;
zz = z(ndx);
th(ndx) = sign(zz).*soft(abs(zz) - lambda);

ndx = (abs(z) > 2*lambda) & (abs(z) <= a*lambda);
zz = z(ndx);
th(ndx) = ((a-1)*zz - sign(zz).*a*lambda)/(a-2);

ndx = abs(z)>a*lambda;
zz = z(ndx);
th(ndx) = zz;
end

function u = soft(x)
u = max(0,x);
end

function th=penalty(z, a, lambda)
% p612 of Clarke's book
th = zeros(size(z));
ndx = abs(z) <= lambda;
zz = z(ndx);
th(ndx) = lambda*abs(zz);

ndx = (abs(z) > lambda) & (abs(z) <= a*lambda);
zz = z(ndx);
th(ndx) = -(abs(zz).^2 - 2*a*lambda*abs(zz)+lambda^2)/(2*(a-1));

ndx = abs(z)>a*lambda;
th(ndx) = (a+1)*lambda^2/2;
end

function out = derivPenalty(z, a, lambda)
out = zeros(size(z));
ndx = z<=lambda;
out(ndx) = lambda;
ndx = z>lambda;
out(ndx) = lambda*soft(a*lambda-z)/((a-1)*lambda);
end


function out = LLA(z, a, lambda, bstar)
out = penalty(bstar, a, lambda) + ...
  derivPenalty(bstar, a, lambda)*(abs(z)-abs(bstar));
end

function out = LQA(z, a, lambda, bstar)
out = penalty(bstar, a, lambda) + ...
  0.5*derivPenalty(bstar, a, lambda)/abs(bstar)*(z.^2-bstar^2);
end

