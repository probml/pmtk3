function prediction = rbmPredict(m, testdata)
% Use RBM to predict discrete labels 
% INPUTS:
% testdata(n,d) in [0,1]
% OUTPUTS
% prediction(n) in {1..C}

% This file is from pmtk3.googlecode.com




numclasses= size(m.Wc, 1);
numcases= size(testdata, 1);
F= zeros(numcases, numclasses);

%set every class bit in turn and find -ve free energy of the configuration
for i=1:numclasses
    y= zeros(numcases, numclasses);
    y(:, i)=1;
    F(:,i) = repmat(m.cc(i),numcases,1).*y(:,i)+ ...
       sum(log(exp(testdata*m.W+ ...
       y*m.Wc+repmat(m.b,numcases,1))+1),2);
end

%take the max
[q, prediction]= max(F, [], 2);  %#ok
end

