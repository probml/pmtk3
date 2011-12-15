%% Compare Gauss, Student T, and Laplacian distributions
%
%%

% This file is from pmtk3.googlecode.com

xs = -4:0.2:4;
v = 1;
mu = 0;

pr{1} = gaussProb(xs, mu, sqrt(v));


% variance of student = dof*sigma^2/(dof-2)
nu = 1;
model.mu = mu;
model.dof = nu;
if nu>2
  sigma2 = v*(nu-2)/nu;
else
  sigma2 = 1;
end
model.Sigma = sigma2;
pr{2} = exp(studentLogprob(model, xs));

% variance of laplace = 2b^2
b = sqrt(v/2);
pr{3} = 1/(2*b)*exp(-abs(xs-mu)/b);

legendStr = {'Gauss', 'Student', 'Laplace'};

%[styles, colors, symbols] =  plotColors;
styles = {'k:',  'b--', 'r-'};


figure; hold on
for i=1:3
  plot(xs, pr{i}, styles{i}, 'linewidth',3, 'markersize', 10);
end
legend(legendStr)
printPmtkFigure('studentLaplacePdf')
title('prob. density functions')

figure; hold on
for i=1:3
  plot(xs, log(pr{i}), styles{i}, 'linewidth', 3, 'markersize', 10);
end
legend(legendStr)
printPmtkFigure('studentLaplaceLogpdf')
title('log prob. density functions')


