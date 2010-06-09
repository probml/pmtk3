data = load('statlog.heart.data'); X = standardizeCols(data(:,1:13)); y = sign(data(:,14)-1.5);
[n,p] = size(X);
X = [ones(n,1) X];
lambda = 2;
prior = [1e-4 zeros(1,p);zeros(p,1) lambda*eye(p)];
nSamples = 500;
s = logist2_FS_Sample(X,y,prior,nSamples);

figure(4);
for i = 1:9
   subplot(3,3,i);
   hist(s(i,:));
   xlim([-1 1]);
   title(sprintf('RJ-Gibbs Var%d',i));
end