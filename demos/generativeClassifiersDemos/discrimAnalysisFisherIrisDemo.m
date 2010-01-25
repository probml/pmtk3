% from documentation of hte 'classify' command in the statistics toolbox
% (type help classify)

load fisheriris
x = meas(51:end,1:2);  % for illustrations use 2 species, 2 columns
y = species(51:end);
[c,err,post,logl,str] = classify(x,x,y,'quadratic');
gscatter(x(:,1),x(:,2),y,'rb','v^')

% Classify a grid of values
[X,Y] = meshgrid(linspace(4.3,7.9), linspace(2,4.4));
X = X(:); Y = Y(:);
C = classify([X Y],x,y,'quadratic');
hold on; gscatter(X,Y,C,'rb','.',1,'off'); hold off

% Draw boundary between two regions
hold on
K = str(1,2).const;
L = str(1,2).linear;
Q = str(1,2).quadratic;
f = sprintf('0 = %g + %g*x + %g*y + %g*x^2 + %g*x.*y + %g*y.^2', ...
	    K,L,Q(1,1),Q(1,2)+Q(2,1),Q(2,2));
ezplot(f,[4 8 2 4.5]);
hold off
title('Classification of Fisher iris data')
