function model = oneVsRestClassifFit(X, y, fitFn)
%% Fit a binary classifier to multiclass data using one vs the rest
N = size(X, 1); 
C = nunique(y);
for c=1:C
    yc = -1*ones(N, 1);
    yc(y==c) = 1;
    model.modelClass{c} = fitFn(X, yc);
end

end