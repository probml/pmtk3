%Random Forest Demo for the prostate data set. Train using fitForest and
%predict using predictForest. 

load prostate;

forest = fitForest(Xtrain,ytrain,'randomFeatures',3,'bagSize',1/3);
yhat = predictForest(forest,Xtest);
error = mse(ytest,yhat)

