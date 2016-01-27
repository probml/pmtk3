foo=importdata('complete_dataset.txt');
names=foo.textdata(:,1);
headers = foo.textdata(1,:);
X=foo.data;
 save('yeastStressGeneExpressionData.mat', 'X', 'names', 'headers');