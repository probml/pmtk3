% plot of EP updates for the TrueSkill model
 

psi = inline('normpdf(x)./normcdf(x)');
lambda = inline('(normpdf(x)./normcdf(x)).*( (normpdf(x)./normcdf(x)) + x)');

xs = -6:0.1:6;
figure;
plot(xs, psi(xs), '-', 'linewidth', 3)
h=title(sprintf('%s function', '\Psi'));
set(h, 'fontsize', 15)
printPmtkFigure('PsiWin')

figure;
plot(xs, psi(-xs), '-', 'linewidth', 3)
h=title(sprintf('%s function for loss', '\Psi'));
set(h, 'fontsize', 15)
printPmtkFigure('PsiLose')

figure;
plot(xs, lambda(xs), '-', 'linewidth', 3)
h=title(sprintf('%s function', '\Lambda'));
set(h, 'fontsize', 15)
printPmtkFigure('LambdaWin')

figure;
plot(xs, lambda(-xs), '-', 'linewidth', 3)
h=title(sprintf('%s function for loss', '\Lambda'));
set(h, 'fontsize', 15)
printPmtkFigure('LambdaLose')