function window = dataWindow(X)
% Find appropriate axis coordinates for the n-by-2 data matrix X
% The output can be passed directly to the axis command.  

% This file is from pmtk3.googlecode.com

    
    assert(size(X, 2) == 2);
    minX1 = min(X(:, 1));
    maxX1 = max(X(:, 1));
    minX2 = min(X(:, 2));
    maxX2 = max(X(:, 2));
    dx1 = 0.15*(maxX1 - minX1);
    dx2 = 0.15*(maxX2 - minX2);
    window = [minX1 - dx1, maxX1 + dx1, minX2 - dx2, maxX2 + dx2];
end
