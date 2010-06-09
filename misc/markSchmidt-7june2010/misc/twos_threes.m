function [X,y] = twos_threes()

load digits;
X = 1-[X(y==2,:);X(y==3,:)];
y = [y(y==2)-3;y(y==3)-2];

size(X)