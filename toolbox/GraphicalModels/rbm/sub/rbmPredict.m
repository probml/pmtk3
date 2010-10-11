function prediction = rbmPredict(m, testdata)
%Use RBM to predict discrete label for testdata

%INPUTS:
%m          ... is the model from rbmFit() consisting of W,b,c,Wc,cc
%testdata   ... binary, or in [0,1] interpreted as probabilities

%OUTPUTS:
%yhat(i) in {1..C} is best guess for label

numclasses= size(m.Wc, 1);
numcases= size(testdata, 1);
F= zeros(numcases, numclasses);

%set every class bit in turn and find -ve free energy of the configuration
for i=1:numclasses
    X= zeros(numcases, numclasses);
    X(:, i)=1;
    F(:,i) = repmat(m.cc(i),numcases,1).*X(:,i)+ ...
       sum(log(exp(testdata*m.W+ ...
       X*m.Wc+repmat(m.b,numcases,1))+1),2);
end

%take the max
[q, prediction]= max(F, [], 2);
end

