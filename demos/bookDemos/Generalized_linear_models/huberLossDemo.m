%% Plot the Huber loss fn compared to L1 and L2
% cf Hastie book 2e p350
%%

% This file is from pmtk3.googlecode.com

err = -3:0.1:3;
L1 = abs(err);
L2 = err.^2;
delta = 1.5;
ind = abs(err) <= delta;
huber = 0.5*ind .* (err.^2) + (1-ind) .* (delta*(abs(err)-delta/2));
vapnik = ind .* 0 + (1-ind) .* (abs(err) - delta);

figure; hold on
plot(err, L2, 'r-', err, L1, 'b:', err, huber, 'g-.','linewidth', 3);
legend('L2','L1','huber', 'location', 'north')
set(gca, 'ylim', [-0.5 5])
printPmtkFigure('huberLoss')

figure; hold on
plot(err, L2, 'r-',  err, vapnik, 'b:', err, huber, 'g-.',...
   'linewidth', 3);
legend('L2',sprintf('%s-insensitive','\epsilon'), 'huber', 'location', 'north')
set(gca, 'ylim', [-0.5 5])
printPmtkFigure('vapnikLoss')
