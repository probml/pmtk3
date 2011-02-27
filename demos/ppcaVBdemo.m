%% Bayesian Probabilistic PCA Imputation Demo
% Reproduce Bishop fig 12.14
% Needs BPCAfill package from http://hawaii.sys.i.kyoto-u.ac.jp/~oba/tools/
%%

% This file is from pmtk3.googlecode.com

setSeed(0);

%n = 100;
n = 300;
d = 10;

%sigma = [5,4,3,2,1*ones(1,6)]; % ICANN'99 
sigma = [1,1,1,0.5*ones(1,7)]; % book p584
Sigma = diag(sigma);
mu = zeros(1,d);
k = 4;
W = zeros(d,d);
for i=1:k
   W(:,i) = gaussSample(mu, sigma(i)*eye(d), 1);
end
Z = randn(d,n);
X = W*Z + randn(d,n);
X = X';

%figure; hintonDiagram(W);  title('truth');
%%
kmax = d-1;
[Xfilled,M] = BPCAfill(X, kmax);  
figure; hintonDiagram(M.W); title('ARD');
printPmtkFigure('ppcaVBhintonArd')

%[Wppca, mu, sigma2, evals, evecs, Xproj, Xrecon]  = ppcaFit(X, kmax);
model = ppcaFit(X, kmax);
Wppca = model.W;
figure; hintonDiagram(Wppca); title('MLE'); 
printPmtkFigure('ppcaVBhintonMle')

