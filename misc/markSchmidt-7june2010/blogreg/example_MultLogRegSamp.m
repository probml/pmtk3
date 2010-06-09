beta=[1 2 1 0; 1 1 0 1; 0 1 2 1];n=1000;p=4;K=3;
X=randn(n,p); e=randn(n,1);
y=zeros(n,K); theta=zeros(K,1);
vInv=0.25*eye(p);numSamples=1000; 

for i=1:n
     for j=1:3
       theta(j)=exp(X(i,:)*beta(j,:)');
     end
       theta=theta/sum(theta);
       y(i,find(mnrnd(1,theta)))=1;
end

betasample=zeros(p,K,numSamples);
betasample= Mlogist2Sample2(X,y,vInv,numSamples,K);

betanew=zeros(p,K);
for i=1:p
    for k=1:K
      betanew(i,k)=mean(betasample(i,k,:));
    end
end

%0.3000    0.3470    0.3530 