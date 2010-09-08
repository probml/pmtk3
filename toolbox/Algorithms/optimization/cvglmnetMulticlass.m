function CVerr = cvglmnetMulticlass(x,y,nfolds,foldid,type,family,options,verbose)
% Do crossvalidation of glmnet model. The coordinate descent algorithm 
% chooses a set of lambda to optimize over based on the input given in
% the options struct.Parameter tuning should be done in such a way that for
% a fixed alpha, a set of lambda values are evaluated. Basically it does
% not matter if lambda corresponds across alpha values, as each cv-plot
% should inspected seperatly.
% So e.g. to find optimal tuning parameters, fit a total of 10 alpha
% values, beeing alpha = 0:0.1:1.lambdas will then be chosen according to 
% the specific alpha. 
% Call: CVerr = cvglmnet(x,y,nfolds,foldid,type,family,options,verbose)
% Example:
% x=randn(100,2000);
% y=randn(100,1);
% g2=randsample(2,100,true);
% CVerr=cvglmnet(x,y,100,[],'response','gaussian',glmnetSet,1);
% CVerr=cvglmnet(x,g2,100,[],'response','binomial',glmnetSet,1);
% x         : Covariates: N*D
% y         : Response : N*1 (for multiclass, y(i) in {1,..,C})
% nfolds    : How many folds to evaluate. nfolds = size(x,1) for LOOCV
% foldid    : foldid(i)=k means use case i on fold k. Use [] for default.
% type      : Ignored. We use squared error for gaussian
%                and classification error for binomial/multinomial.
% family    : 'gaussian', 'binomial', or 'multinomial'
% options   : See function glmnetSet()
% verbose   : Print model plot
% 
%PMTKauthor Bjorn Skovlund Dissing 
%PMTKurl http://www-stat.stanford.edu/~tibs/glmnet-matlab/
%PMTKdate 7 Sep 2011, 27-02-2010
%PMTKmodified Kevin Murphy, to support multinomial responses
% See also http://code.google.com/p/pmtk3/ for related code

glmnet_object = glmnet(x, y, family,options);
options.lambda = glmnet_object.lambda;
options.nlambda = length(options.lambda);
N = size(x,1);
if (isempty(foldid))
  % randsample is a stats toolbox function
    foldid = randsample([repmat(1:nfolds,1,floor(N/nfolds)) 1:mod(N,nfolds)],N);
else
    nfolds = max(foldid);
end

switch lower(family)
  case 'gaussian'
    type = 'response';
  otherwise
    type = 'class';
end

predmat = glmnetPredict(glmnet_object, type, x, options.lambda);

for i=1:nfolds
    which=foldid==i;
    if verbose, disp(['Fitting fold # ' num2str(i) ' of ' num2str(nfolds)]);end
    cvfit = glmnet(x(~which,:), y(~which),family, options);
    predmat(which,:) = glmnetPredict(cvfit, type,x(which,:),options.lambda);
end
% predmat is N*nlambda
yy=repmat(y,1,length(options.lambda));
switch lower(family)
  case 'gaussian'
    cvraw=(yy-predmat).^2;
  otherwise
    %cvraw=-2*((yy==2).*log(predmat)+(yy==1).*log(1-predmat));
    cvraw=double(yy~=predmat);
end
CVerr.cvm=mean(cvraw);
CVerr.stderr=sqrt(var(cvraw)/N);
CVerr.cvlo=CVerr.cvm-CVerr.stderr;
CVerr.cvup=CVerr.cvm+CVerr.stderr;
% if there are several minima, choose largest lambda of the smallest cvm
CVerr.lambda_min=max(options.lambda(CVerr.cvm<=min(CVerr.cvm)));
%Find stderr for lambda(min(sterr))
semin=CVerr.cvup(options.lambda==CVerr.lambda_min);
% find largest lambda which has a smaller mse than the stderr belonging to
% the largest of the lambda belonging to the smallest mse
% In other words, this defines the uncertainty of the min-cv, and the min
% cv-err could in essence be any model in this interval.
CVerr.lambda_1se=max(options.lambda(CVerr.cvm<semin));
CVerr.glmnetOptions=options;
CVerr.glmnet_object = glmnet_object;
if verbose, cvglmnetPlot(CVerr);end
end