function p = plotCVgrid(params, mu, bestParams)
% Plot Cross validation results in 2D

sz = nunique(params);
nrows = sz(1);
ncols = sz(2);
X = reshape(params(:, 1), nrows, ncols);
Y = reshape(params(:, 2), nrows, ncols);
Z = reshape(mu, nrows, ncols);
p = surf(X, Y, Z);
view([0, 90]);
colorbar;
xlabel('first model param');
ylabel('second model param');
title(sprintf('Color Denotes Score\nVal1: %f\nVal2: %f',bestParams(1), bestParams(2)));
axis tight;
box on;

% warning('off','MATLAB:Axes:NegativeDataInLogAxis');
% if(isequal(logspace(log10(min(mu(:, 1))), log10(max(mu(:, 1))),nunique(mu(:, 1)))',unique(mu(:, 1))))
%     set(gca,'Xscale','log');
% end
% if(isequal(logspace(log10(min(mu(:, 2))), log10(max(mu(:, 2))),nunique(mu(:, 2)))',unique(mu(:, 2))))
%     set(gca,'Yscale','log');
% end

end


