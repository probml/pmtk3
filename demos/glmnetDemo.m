

if ~glmnetInstalled
    fprintf('cannot run %s without glmnet; skipping\n', mfilename());
    return;
end

if 0
x=randn(100,20);
y=randn(100,1);
g2=randsample(2,100,true);
g4=randsample(4,100,true);
fit1=glmnet(x,y);
glmnetPrint(fit1);
glmnetCoef(fit1,0.01) % extract coefficients at a single value of lambda
glmnetPredict(fit1,'response',x(1:10,:),[0.01,0.005]') % make predictions
fit2=glmnet(x,g2,'binomial');
fit3=glmnet(x,g4,'multinomial');
end

if 0
clear all
load('prostateStnd');
options = glmnetSet;

% ridge path

% This file is from pmtk3.googlecode.com

options.alpha = 0; 
options.nlambda = 10;
fit = glmnet(X, y, 'gaussian', options);
%df = linregDofL2(X, fit.lambda)
figure; plot(fit.beta', '-o'); title('ridge')

% lasso path
options.alpha = 1; 
options.nlambda = 30;
fit = glmnet(X, y, 'gaussian', options);
figure; plot(fit.beta', '-o'); title('lasso')

% lasso path using lars
XS = standardize(X);
w = lars(XS,y);
figure; plot(w, '-o'); title('lars')

% cv
options = glmnetSet;
options.nlambda = 10;
CVerr=cvglmnet(X,y,10,[],'response','gaussian',options,1);

end

if 1
  load('soy'); % 3 class, X is 307*35, Y is 307*1
  family = 'multinomial';
options = glmnetSet;
models = glmnet(X, Y, family, options);

%options.nlambda = 10;
nfolds = 5; foldid = []; type = []; 
verbose = 1;
CVerr=cvglmnetMulticlass(X,Y,nfolds,foldid, type, family, options, verbose);
end
