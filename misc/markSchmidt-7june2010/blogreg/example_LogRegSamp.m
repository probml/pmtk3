data = load('statlog.heart.data'); X = standardizeCols(data(:,1:13)); y = sign(data(:,14)-1.5);
[n,p] = size(X);
X = [ones(n,1) X];
lambda = 2;
prior = [0 zeros(1,p);zeros(p,1) lambda*eye(p)];
nSamples = 500;
s0 = logist2SampleMH(X,y,prior,nSamples);
s = logist2Sample(X,y,prior,nSamples);
s2 = logist2Sample2(X,y,prior,nSamples);

figure(1);
for i = 1:9
   subplot(3,3,i);
   hist(s0(i,:));
   xlim([-1 1]);
title(sprintf('MH Var%d',i));
end

figure(2);
for i = 1:9
   subplot(3,3,i);
   hist(s2(i,:));
   xlim([-1 1]);
   title(sprintf('Gibbs2 Var%d',i));
end

figure(3);
for i = 1:9
   subplot(3,3,i);
   hist(s(i,:));
   xlim([-1 1]);
   title(sprintf('Gibbs1 Var%d',i));
end


