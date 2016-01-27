function [data] = adultDataPreprocess()
% remove all instances with missing data
% store types of data c=cts, b=binary (0:1), m=multinomial (1:C)
% Make binary variables 0:1

train = textread('adultNumericTrain.txt');
test = textread('adultNumericTest.txt');
data.varNames = {'age','workclass','fnlwgt','education','eduction_num','marital_status','occupation',...
  'relationship','race','sex','capital_gain','capital_loss','hrs_per_week', 'country','income'};

Ntrain  = size(train,1);
Ntest  = size(test,1);
N = Ntrain+Ntest;
data.isTest = false(1,N);
data.isTest(Ntest+1:end) = true;
data.X = [train; test];
data.types = 'cmcmcmmmmbcccmb';

% remove all the instances with missing data
vec = sum(data.X,2);
idx = ~isnan(vec);
data.X = data.X(idx,:);
data.isTest = data.isTest(idx);

ndx = find(data.types=='b');
for j=ndx(:)'
  data.X(:,j) = convertLabelsTo01(data.X(:,j));
end

if 0
  D = size(data.X,2);
  for j=1:D
    figure
    hist(data.X(:,j));
    title(sprintf('%d %s', j, safeStr(data.varNames{j})));
  end
  placeFigures
end

% We skip the following features which are not very variable
 % skip 11 (capgain), 12 (caploss), 14 (country)
skip = [11 12 14];
D = size(data.X,2);
keep = setdiff(1:D, skip);
data.X = data.X(:,keep);
data.varNames = data.varNames(keep);
data.types = data.types(keep);

end