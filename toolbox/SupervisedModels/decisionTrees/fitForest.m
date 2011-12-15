function forest = fitForest(X,y,varargin)
%Fit a random forest. Rows of X are examples, columns are features. See
%dtfit for tree specific documentation. Fits 'ntrees' on randomly selected
%subsets of the training examples in X, (with replacement). At each node in
%each tree, the best of a random selection of candidate features is used to
%split. Returns an object array of trees of size 1-by-ntrees
%
%Optional named parameters:
%  'ntrees' (default = 100) The number of trees to create.
%  'randomFeatures' (default = 2) The number of randomly selected features
%       to consider for splits at each node of each tree. 
%  'bagSize' (default = 1/3) The proportion of training examples used to
%       fit each tree, (subset selected randomly with replacement). 

%http://stat-www.berkeley.edu/users/breiman/RandomForests/cc_home.htm

  [nexamples,nfeatures] = size(X);
  [ntrees,randomFeatures,bagSize] = process_options(varargin,...
      'ntrees',100,'randomFeatures',2,'bagSize',1/3);

    for t = 1:ntrees
        
        perm = randperm(nexamples);
        ndx = perm(1:floor(bagSize*nexamples));
        Xtrain = X(ndx,:);
        ytrain = y(ndx,:);
        forest(t) = dtfit(Xtrain,ytrain,'randomFeatures',randomFeatures);
   
    end

    

end