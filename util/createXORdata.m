function [X, y] =  createXORdata(doplot)
    
    if nargin < 1, doplot = false; end
    off1 = gaussSample([1, 1], 0.5*eye(2), 20);
    off2 = gaussSample([5, 5], 0.5*eye(2), 20);
    on1  = gaussSample([1, 5], 0.5*eye(2), 20);
    on2  = gaussSample([5, 1], 0.5*eye(2), 20);
    X    = [off1; off2; on1; on2];
    y    = [zeros(size(off1, 1) + size(off2, 1), 1); ones(size(on1, 1) + size(on2, 1), 1)];
    if doplot
        plot(X(y==0, 1), X(y==0, 2), 'ob', 'MarkerSize', 8); hold on
        plot(X(y==1, 1), X(y==1, 2), '+r', 'MarkerSize', 8); 
    end
    
end