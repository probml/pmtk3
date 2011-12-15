function [S,K] = nn_cov_mat3(vec);
% Compute the covariance matrix for a 1 hidden layer neural net
% with input bias variance vara, input wts variance varu, 
% output weight variance varout and output bias var varb
% and # hidden units = nhid
%
% 13 May 1996, modified from nn_cov_mat.m
%
% modified from nn_cov_nat2 by removing varnoi contribution
  % ckiw, 8 June 2005

% differs from nn_cov_mat.m in that it takes varb as well

global XVEC XTEST;
n = length(XVEC);
ltest = length(XTEST);
S = zeros(n,n);
K = zeros(ltest,n);
%varnoi = 0.0025;  % noise level used on intar2d data
%N = varnoi * eye(n);

% parse input vars
nhid = vec(1);
varu = vec(2)*vec(2); 	% inputs are std's not variances
vara = vec(3)*vec(3);
varout = vec(4)*vec(4);
varb = vec(5)*vec(5);


% setup S and K

f1= 2/pi;

for i = 1:n
  cii = varu*XVEC(:,i)'*XVEC(:,i) + vara;
  for j = i:n
    cjj = varu*XVEC(:,j)'*XVEC(:,j) + vara;
    cij = varu*XVEC(:,i)'*XVEC(:,j) + vara;
    den = (sqrt(1+2*cii))*(sqrt(1+2*cjj));
    S(i,j) = varb + varout*nhid*f1*asin(2*cij/den);
    if (i ~= j)
      S(j,i) = S(i,j);
    end
  end


  for k = 1:ltest
    ckk = varu*XTEST(:,k)'*XTEST(:,k) + vara;
    cik = varu*XTEST(:,k)'*XVEC(:,i) + vara;
    den = (sqrt(1+2*cii))*(sqrt(1+2*ckk));
    K(k,i) = varb + varout*nhid*f1*asin(2*cik/den);
  end

end  % matches i = 1:n






