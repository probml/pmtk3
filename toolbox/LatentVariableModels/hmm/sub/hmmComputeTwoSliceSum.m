function xiSummed = hmmComputeTwoSliceSum(alpha, beta, A, B)
%% Compute the sum of the two-slice distributions over hidden states
%
% Let K be the number of hidden states, and T be the number of time steps.
% Let S(t) denote the hidden state at time t, and y(t) be the (not
% necessarily scalar) observation at time t. 
%
%% INPUTS:
% 
% alpha, and beta are computed using e.g. hmmFwdBack, A is the state
% transition matrix, whose *rows* sum to one, and B is the soft evidence. 
% 
% alpha(j, t)      = p( S(t) = j  | y(1:t)    )   (KxT) 
% beta (j, t) propto p( y(t+1:T)  | S(t)   = j)   (KxT)
% A    (i, j)      = p( S(t) = j  | S(t-1) = i)   (KxK) 
% B    (j, t)      = p( y(t)      | S(t)   = j)   (KxT)
% 
%% OUTPUT: 
% xiSummed(i, j) = sum_t=2:T p(S(t) = i, S(t+1) = j | y(1:T)), t=2:T   (KxK)
% The output constitutes the expected sufficient statistics for the 
% transition matrix, for a given observation sequence. 
%%

% This file is from pmtk3.googlecode.com

[K, T] = size(B);
xiSummed = zeros(K, K);
for t = T-1:-1:1
    b        = beta(:,t+1) .* B(:,t+1);
    xit      = A .* (alpha(:,t) * b');
    xiSummed = xiSummed + xit./sum(xit(:));
end
end
