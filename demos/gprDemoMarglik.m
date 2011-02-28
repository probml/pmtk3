function gprDemoMarglik()

% Make figure 5.5 of Rasmussen and Williams book
%PMTKauthor Carl Rasmussen

hhh=figure(1)
clf
set(gca,'FontSize',22)
n = 7;
rand('state',28);
randn('state',28);
xs = 15*(rand(n,1)-0.5);
K = inline('exp(-0.5*(repmat(p'',size(q))-repmat(q,size(p''))).^2)');
fs = chol(K(xs,xs)+0.01*eye(n))'*randn(n,1);      % Cholesky decomp.
n=41;
[X,Y] = meshgrid(linspace(log(0.1),log(80),n), linspace(log(0.03),log(3),n));
for i=1:n*n
  try,
%   [a b c] = minimize([X(i) -2 Y(i)]','gpS00evidence',-100,xs,fs,[0 1 0]');
%   Z(i) = b(end);
    Z(i)=gpS00evidence([X(i) 0 Y(i)]',xs,fs,[0 1 0]');
  catch
    Z(i) = 100;
  end
end
Z(Z>100)=100;
[cs,hh]=contour(exp(X),exp(Y),-reshape(Z,n,n),-[8.3 8.5 8.9 9.3 9.8 11.5 15])
set(hh,'LineWidth',2)
set(gca,'XScale','log','YScale','log')   
xlabel('characteristic lengthscale')
ylabel('noise standard deviation')
%axis square
[a1 b1 c1]=minimize([log(1) 0 log(0.2)]',@gpS00evidence,-100,xs,fs,[1 0 1]');
[a2 b2 c2]=minimize([log(10) 0 log(0.8)]',@gpS00evidence,-100,xs,fs,[1 0 1]');
hold on
plot(exp(a1(1)),exp(a1(3)),'+','MarkerSize',14,'LineWidth',2)
plot(exp(a2(1)),exp(a2(3)),'+','MarkerSize',14,'LineWidth',2)
set(hhh,'PaperPosition', [0.25 2.5 8 6])
% print -depsc local1.eps

hhh2=figure(2);
clf
set(gca,'FontSize',24)
x = linspace(-7.5,7.5,201)';
[mu S] = gpS00evidence(a1,xs,fs,1,x);
z = 7.47;
xxs = max(min([x; flipdim(x,1)],z),-z);
ys = max(min([mu+2*sqrt(S);flipdim(mu-2*sqrt(S),1)],z/2),-z/2);
fill(xxs,ys,[7 7 7]/8, 'EdgeColor', [7 7 7]/8)
hold on
plot(xs,fs,'+','MarkerSize',14,'LineWidth',2)
plot(x,mu,'-','LineWidth',2)
axis([-7.5 7.5 -2 2.7])
%axis square
xlabel('input, x')
ylabel('output, y')
set(hhh2,'PaperPosition', [0.25 2.5 8 6])
% print -deps local2.eps


hhh3=figure(3);
clf
set(gca,'FontSize',24)
x = linspace(-7.5,7.5,201)';
[mu S] = gpS00evidence(a2,xs,fs,1,x);
z = 7.47;
xxs = max(min([x; flipdim(x,1)],z),-z);
ys = max(min([mu+2*sqrt(S);flipdim(mu-2*sqrt(S),1)],z/2),-z/2);
fill(xxs,ys,[7 7 7]/8, 'EdgeColor', [7 7 7]/8)
hold on
plot(x,mu,'-','LineWidth',2)
plot(xs,fs,'+','MarkerSize',14,'LineWidth',2)
axis([-7.5 7.5 -2 2.7])
%axis square
xlabel('input, x')
ylabel('output, y')
set(hhh3,'PaperPosition', [0.25 2.5 8 6])
% print -deps local3.eps

end

function [out1, out2, out3] = gpS00evidence(X, input, target, mask, test);

% gpS00: Gaussian process regression with "squared negative exponential"
% covariance function and independent Gaussian noise model. Two modes are
% possible: training and prediction: if no test data are given, the function
% returns minus the log likelihood and its partial derivatives with respect to
% the hyperparameters; this mode is used to fit the hyperparameters. If test
% data are given, then (marginal) Gaussian predictions are computed, whose mean
% and (noise free) variance are returned.
%
% usage: [fX dfX] = gpS00(X, input, target)
%    or: [mu S2]  = gpS00(X, input, target, test)
%
% where:
%
%   X      is a (column) vector (of size D+2) of hyperparameters
%   input  is a n by D matrix of training inputs
%   target is a (column) vector (of size n) of targets
%   test   is a nn by D matrix of test inputs
%   fX     is the returned value of minus log likelihood
%   dfX    is a (column) vector (of size D+2) of partial derivatives
%            of minus the log likelihood wrt each of the hyperparameters
%   mu     is a (column) vector (of size nn) of prediced means
%   S2     is a (column) vector (of size nn) of predicted variances
%
% where D is the dimension of the input. The form of the covariance function is
%
% C(x^p,x^q) = v^2 * exp[-(x^p - x^q)'*inv(P)*(x^p - x^q)/2]
%            + u^2 * delta_{p,q}
%
% where the first term is the squared negative exponential and the second term
% with the kronecker delta is the noise contribution. The P matrix is diagonal
% with "Automatic Relevance Determination" (ARD) or "input length scale"
% parameters w_1^2,...,w_D^2; The hyperparameter v is the "signal std dev" and
% u is the "noise std dev". All hyperparameters are collected in the vector X
% as follows:
%
% X = [ log(w_1)
%       log(w_2) 
%        .
%       log(w_D)
%       log(v)
%       log(u) ]
%
% Note: the reason why the log of the parameters are used in X is that this
% often leads to a better conditioned (and unconstrained) optimization problem
% than using the raw hyperparameters themselves.
%
% This function can conveniently be used with the "minimize" function to train
% a Gaussian process:
%
% [X, fX, i] = minimize(X, 'gpS00', length, input, target)
%
% See also: minimize, hybrid
%      
% (C) Copyright 1999 - 2003, Carl Edward Rasmussen (2003-11-03).


[n, D] = size(input);         % number of examples and dimension of input space
input = input ./ repmat(exp(X(1:D))',n,1);

% first, we write out the covariance matrix Q

Q = zeros(n,n);
for d = 1:D
  Q = Q + (repmat(input(:,d),1,n)-repmat(input(:,d)',n,1)).^2;
end
Q = exp(2*X(D+1))*exp(-0.5*Q);

if nargin == 4   % if no test cases, we compute the negative log likelihood ...

  W = inv(Q+exp(2*X(D+2))*eye(n));               % W is inv (Q plus noise term)
  invQt = W*target;                               % don't compute determinant..
  logdetQ = 2*sum(log(diag(chol(Q+exp(2*X(D+2))*eye(n)))));        % ..directly
  out1 = 0.5*logdetQ + 0.5*target'*invQt + 0.5*n*log(2*pi);

  % ... and its partial derivatives

  out2 = zeros(D+2,1);                  % set the size of the derivative vector
  W = W-invQt*invQt';
  Q = W.*Q;
  for d = 1:D
    out2(d) = ...
            sum(sum(Q.*(repmat(input(:,d),1,n)-repmat(input(:,d)',n,1)).^2))/2;
  end 
  out2(D+1) = sum(sum(Q));
  out2(D+2) = trace(W)*exp(2*X(D+2));

  out2 = out2 .* mask;
  out3 = [-0.5*logdetQ -0.5*target'*invQt];

else                    % ... otherwise compute (marginal) test predictions ...

  [nn, D] = size(test);     % number of test cases and dimension of input space
  test = test ./ repmat(exp(X(1:D))',nn,1);

  a = zeros(n, nn);    % compute the covariance between training and test cases
  for d = 1:D
    a = a + (repmat(input(:,d),1,nn)-repmat(test(:,d)',n,1)).^2;
  end
  a = exp(2*X(D+1))*exp(-0.5*a);

  % ... write out the desired terms

  if nargout == 1
    out1 = a'*((Q+exp(2*X(D+2))*eye(n))\target);              % predicted means
  else
    invQ = inv(Q+exp(2*X(D+2))*eye(n));
    out1 = a'*(invQ*target);                                  % predicted means
    out2 = exp(2*X(D+1)) - sum(a.*(invQ*a),1)'; % predicted noise-free variance
  end

end
end
