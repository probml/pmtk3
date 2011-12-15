%Simple test to make sure we can learn an arbitrary boolean function. 

table = dec2bin(0:(2^8)-1);
X = false(size(table));
X(table == '1') = 1;
y1 = (sum(X,2) <= 4) | (~X(:,5) & X(:,1));  
y2 = X(:,7) & X(:,4);
y = [y1 y2];                                %Multivariate output


tree1 = dtfit(X,y,'splitMeasure','IG');
tree2 = dtfit(X,y,'splitMeasure','GINI');
dtdisplay(tree1);
dtdisplay(tree2);



yhat1 = dtpredict(tree1,X);
yhat2 = dtpredict(tree2,X);

assert(all(sum(yhat1 ~= y) == 0)); 
assert(all(sum(yhat2 ~= y) == 0));


