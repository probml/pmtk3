function model = oneVsRestClassifFit(X, y, fitFn, varargin)
%% Fit a binary classifier to multiclass data using one vs the rest

% This file is from pmtk3.googlecode.com


[binaryRange] = process_options(varargin, 'binaryRange', [-1 1]); 
off = binaryRange(1);
on  = binaryRange(2); 


N = size(X, 1); 
C = nunique(y);
for c=1:C
    yc = off*ones(N, 1);
    yc(y==c) = on;
    model.modelClass{c} = fitFn(X, yc);
end
model.binaryRange = binaryRange; 

end
