function [f,g,H,T] = SquaredError(w,X,y)
% w(feature,1)
% X(instance,feature)
% y(instance,1)


if nargout < 3
    % Use 2 matrix-vector products with X
    Xw = X*w;
    res = Xw-y;
    f = sum(res.^2);

    if nargout > 1
        g = 2*(X.'*res);
    end
else
    % Explicitly form X'X and do 2 matrix-vector product
    [n,p] = size(X);
    XX = X.'*X; % np^2
    
    if n < p % Do two matrix-vector products with X
        Xw = X*w;
        res = Xw-y;
        f = sum(res.^2);
        g = 2*(X.'*res);
    else % Do 1 matrix-vector product with X and 1 with X'X
        XXw = XX*w;
        Xy = X.'*y;
        f = w.'*XXw - 2*w.'*Xy + y.'*y;
        g = 2*XXw - 2*Xy;
    end

    H = 2*XX;
    if nargout > 3
        p = length(w);
        T = zeros(p,p,p);
    end

end