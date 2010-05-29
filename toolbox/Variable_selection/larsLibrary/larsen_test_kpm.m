% fig 3 of Zou and Hastie JRSSB 2005



loadData('prostate');
ndx = find(istrain);
y = y(ndx); X = X(ndx,:);

%X = diabetes.x2;
X = normalize(X);
%y = diabetes.y;
y = centerCols(y);
[n p] = size(X);

lambda2 = 1000;
b1 = larsen(X, y, lambda2, 0, 1);
t1 = sum(abs(b1),2)/max(sum(abs(b1), 2));

figure;
plot(t1, b1, '-');
title('Elastic net on prostate data')
legend(names(1:8), 'location', 'northwest')
set(gca,'ylim',[-1 8])
xlabel('s=||w(r,:)||_1 / ||w(end,:)||_1')
