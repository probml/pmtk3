function [w, b] = perceptronFit(X, y)
%% Classic perceptron algorithm
% X(i,:) for case i
% y(i) = -1 or +1
%PMTKauthor Thomas Hoffman

% This file is from pmtk3.googlecode.com


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
    if (errors==0)
        break;
    end
end


end
