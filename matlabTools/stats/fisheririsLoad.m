
% This file is from pmtk3.googlecode.com

function [X,y,classnames,varnames] = fisheririsLoad()

loadData('fisherIrisData') % meas 150x4, species 150x1 cell array
X  = meas;
classnames = {'setosa', 'versicolor', 'virginica'};
varnames = {'sepal length', 'sepal width', 'petal length', 'petal width'};
y = zeros(1,150);
for c=1:3
  ndx = strmatch(classnames{c},species);
  y(ndx) = c;
end
