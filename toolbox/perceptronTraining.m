function [w,b] = perceptronTraining(X, y)
% X(i,:) for case i
% y(i) = -1 or +1
% Based on code by Thomas Hoffman

labels = y; features = X';
[n d] = size(X);

w = zeros(d,1);
b = zeros(1,1);
max_iter = 100;
for iter=1:max_iter
  errors = 0;
  for i=1:n
    if ( labels(i) * ( w' * features(:,i) + b ) <= 0 )
      w = w + labels(i) * features(:,i);
      b = b + labels(i);
      errors = errors + 1;
    end
  end
  fprintf('Iteration %d, errors = %d\n', iter, errors);
  if (errors=0)
    break;
  end
end
