
function p = plotCVgrid(params, mu, bestParams, params1, params2)
% Plot Cross validation results in 2D

% This file is from pmtk3.googlecode.com


if nargin < 4 || isempty(params1)
  params1 = unique(params(:,1));
  params2 = unique(params(:,2));
end

sz = nunique(params);
nrows = sz(1);
ncols = sz(2);
X = reshape(params(:, 1), nrows, ncols);
Y = reshape(params(:, 2), nrows, ncols);
Z = reshape(mu, nrows, ncols);
%p = surf(X, Y, Z);
%view([0, 90]);
imagesc(Z);
set(gca, 'ytick', 1:numel(params1), 'yticklabel', params1)
set(gca, 'xtick', 1:numel(params2), 'xticklabel', params2)
colorbar;
xlabel('first model param');
ylabel('second model param');
ndx1 = find(bestParams(1)==params1);
ndx2 = find(bestParams(2)==params2);
%title(sprintf('Color Denotes Score\nVal1: %f\nVal2: %f',bestParams(1), bestParams(2)));
title(sprintf('Lowest cost at col = %d, row = %d', ndx2, ndx1));
%axis tight;
%box on;
% warning('off','MATLAB:Axes:NegativeDataInLogAxis');
% if(isequal(logspace(log10(min(mu(:, 1))), log10(max(mu(:, 1))),nunique(mu(:, 1)))',unique(mu(:, 1))))
%     set(gca,'Xscale','log');
% end
% if(isequal(logspace(log10(min(mu(:, 2))), log10(max(mu(:, 2))),nunique(mu(:, 2)))',unique(mu(:, 2))))
%     set(gca,'Yscale','log');
% end

end


