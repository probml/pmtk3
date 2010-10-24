function X = addOnes(X)
% Add a column of ones to X

% This file is from pmtk3.googlecode.com

    X = [ones(size(X, 1), 1), X];
end
