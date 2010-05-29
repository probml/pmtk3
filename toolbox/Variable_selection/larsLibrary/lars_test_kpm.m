clear all

if 1
  % p65 of Hastie et al
  loadData('prostate');
  ndx = find(istrain);
  y = y(ndx); X = X(ndx,:);
else
  loadData('diabetes');
  X = diabetes.x;
  y = diabetes.y;
  [n p] = size(X);
  for i=1:p
    names{i} = sprintf('x%d', i); 
  end
end

%X = normalize(X);
X = centerCols(X); X = standardize(X);
y = centerCols(y);

[n p] = size(X);

lambdas = [logspace(4, 0, 20) 0];
%[beta, df] = ridgePathSimple(X, y,  lambdas);
beta = lars(X, y, 'lasso', 0, 0, [], 1);

figure(1);clf
s = sum(abs(beta),2)/sum(abs(beta(end,:)));
plot(s, beta, '.-');
legend(names)

[s_opt, b_opt, res_mean, res_std] = crossvalidate2(@lars, 10, 1000, X, y, 'lasso', 0, 0, [], 0);
%[s_opt, b_opt, res_mean, res_std] = crossvalidate2(@ridgePathSimple, 10, 1000, X, y, lambdas);
figure(2);clf
cvplot(s_opt, res_mean, res_std);

figure(3);clf
k = length(res_mean);
ndx = 1:(k/10):k;
errorbar(res_mean(ndx), res_std(ndx));

figure(1); hold on
axis tight;
ax = axis;
line([s_opt s_opt], [ax(3) ax(4)], 'Color', 'r', 'LineStyle', '-.');


