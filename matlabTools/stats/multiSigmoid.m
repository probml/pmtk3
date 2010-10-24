function [P] = multiSigmoid(X, w)
% Softmax function
%#eml    
% X is n*d
% w is d*(C-1) last column is all 0s
% P is n*C
%
% Based on code by Balaji Krishnapuram

% This file is from pmtk3.googlecode.com


[N,d]=size(X);        %X->Nxd
W=reshape(w,d,[]);

M=size(W,2)+1; % M = nclasses

% Activation for the sigmoids:
a=[X*W zeros(N,1)];   %a->N*(M)

% Ensure that sum(exp(a), 2) does not overflow
maxcut = log(realmax) - log(M);
a = min(a, maxcut);

% Ensure that exp(a) > 0
mincut = log(realmin);
a = max(a, mincut);

% Compute the Probabilities:
temp = exp(a);
P = temp./(sum(temp, 2)*ones(1,M));

% Ensure that log(P) is computable
%P(P<realmin) = realmin;

% Use non-vectorized check for EML compliance. 
for i=1:numel(P(:))
   if(P(i) < realmin)
       P(i) = realmin;
   end
end

end
