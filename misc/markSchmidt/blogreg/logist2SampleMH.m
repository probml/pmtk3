function [beta] = logist2SampleMH(X,y,vInv,numSamples)
% Metropolis-Hastings Sampler for Binary Logistic Regression

[n,p] = size(X);

% Start at Maximum Likelihood Solution
[beta,C] = L2LogReg_IRLS(X,y,vInv);

sigma_MH = 1; % Adjustable scale parameter

accept = 0;
for i = 1:numSamples

    % Do a random walk based on previous value,
    % scale, and asymptotic covariance
    beta_cand = mvnrnd(beta(:,i),sigma_MH*C)';

    % Compute MH acceptance probability
    r = exp(NegLogPosterior(beta(:,i),X,y,vInv)-NegLogPosterior(beta_cand,X,y,vInv));

    if rand < r
        beta(:,i+1) = beta_cand;
        fprintf('Accept: Sample %d, aRatio = %.2f\n',i,accept/i);
        accept = accept+1;
    else
        beta(:,i+1) = beta(:,i);
    end

    % Fix scale if acceptance ratio too high/low
    if mod(i,50)
        if accept/i < .25
            sigma_MH = sigma_MH/2;
        elseif accept/i > .5
            sigma_MH = sigma_MH*2;
        end
    end
end

end

function [f] = NegLogPosterior(w,X,y,vInv)
[n,p] = size(X);
Xw = X*w;
yXw = y.*Xw;
sig = 1./(1+exp(-yXw));
f = sum(mylogsumexp([zeros(n,1) -yXw])) + (1/2)*w'*vInv*w;
end