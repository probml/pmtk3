function data = loadHastieMixtureData()
% Load Hastie mixture data from 
% http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/mixture.example.data
% http://www-stat.stanford.edu/~tibs/ElemStatLearn/datasets/mixture.example.info
%
%% Data
% Data is a struct with the following fields:
% x	       - 200 x 2 matrix of training predictors
% y	       - class variable; logical vector of TRUES and
% 	         FALSES - 100 of each
% xnew	   - matrix 6831 x 2 of lattice points in predictor space
% prob	   - vector of 6831 probabilities (of class TRUE) at each
% 	         lattice point
% marginal - marginal probability at each lattice point
% px1	   - 69 lattice coordinates for x.1
% px2	   - 99 lattice values for x.2  (69*99=6831)
% means	   - 20 x 2 matrix of the mixture centers, first ten for one
% 	         class, next ten for the other
%% Comments from mixture.example.info
% So for example, the Bayes error rate is computed as
% bayes.error<-sum(marginal*(prob*I(prob<0.5)+(1-prob)*I(prob>=.5)))
%
% If pred is a vector of predictions (of the logit, say):
%
% pred<-predict.logit(xnew)
%
% then the test error is
%
% test.error<-sum(marginal*(prob*I(pred <0)+(1-prob)*I(pred>=0)))
%%
g = getText('mixture.example.data');
%g(1:9)         = string header
%g(10:409)      = X(:) - two features
%g(410:417)     = string header
%g(418:617)     = y in {0, 1}
%g(618:623)     = string header
%g(624:14285)   = xnew(:) - two features
%g(14286:14296) = string header
%g(14297:21127) = 1:6831
%g(21128:21142) = string header
%g(21143:27973) = prob
%g(27974:27976) = string header
%g(27976:34807) = 1:6831
%g(34808:34813) = string header 
%g(34814:41644) = marginal
%g(41645:41647) = string header
%g(41648:48478) = 1:6831
%g(48479:48481) = string header
%g(48482:48550) = px1
%g(48551:48553) = string header
%g(48554:48652) = px2
%g(48653:48658) = string header
%g(48659:48698) = means
%g(48699:end)   = string header

data.X = reshape(str2double(g(10:409)), [], 2);
data.y = str2double(g(418:617));
data.xnew = reshape(str2double(g(624:14285)), [], 2);
data.prob = str2double(g(21143:27973));
data.marginal = str2double(g(34814:41644)); 
data.px1 = str2double(g(48482:48550));
data.px2 = str2double(g(48554:48652));
data.means = str2double(g(48659:48698));
data.bayesError = sum(data.marginal.*(data.prob.*(data.prob < 0.5) + (1-data.prob).*(data.prob >= 0.5)));

end