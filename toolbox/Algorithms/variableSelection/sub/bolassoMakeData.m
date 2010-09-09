function [Xdata,ydata,W] = bolassoMakeData(n,d,r,nDataSets,requireConsistent,noise)
%Generate synthetic data as per section 4.1 in 
%Bolasso: Model Consistent Lasso Estimation throught the Bootstrap by
%Fracis R. Bach, available at www.di.ens.fr/~fbach/icml_bolasso.pdf.
%
% n          - number of examples
% d          - number of features
% r          - number of relevant features
%
% nDataSets  - number of data sets, each with the above specs all drawn
%              from the same distribution, i.e. all of the X's drawn using
%              the same cov matrix and y's generated using the same loading
%              vector, W.
%
% consistent - if true only sign consistent data is  returned. 
%              If false, only sign inconsistent data is returned. 
%              Sign consistency is w.r.t. equation 2 in 
%              Bolasso: Model Consistent Lasso Estimation throught the 
%              Bootstrap by Francis R. Bach. Available at 
%              www.di.ens.fr/~fbach/icml_bolasso.pdf
%              ||(Q_{J^cJ})*(Q_{JJ}^-1)*sign(W_J)||_inf <= 1
%
% noise   -   standard deviation of noise added to y (default 0.1)
%
% OUTPUTS
% Xdata      - A cell array of n-by-d random matrices whose only relevent 
%              features are columns 1:r.  
%
% ydata      - A cell array of n-by-1 target/output random vectors. 
%
% W      -    the d-by-1 random loading vector used to generate all of 
%             the y vectors. 
%
% check  -    the numerical value of the consistency check, i.e. 
%             ||(Q_{J^cJ})*(Q_{JJ}^-1)*sign(W_J)||_inf
%
% If nDataSets = 1, X,y are unwrapped yielding numeric matricies not cell
% arrays.
%

% This file is from pmtk3.googlecode.com



if nargin < 6, noise = 0.1; end

Xdata = cell(1,nDataSets);
ydata = cell(1,nDataSets);

done = false;
maxIter= 100;
iter = 1;
while(~done) %keep looping until we find a distribution that matches the consistency criteria
    mu = zeros(1,d);
    G = randn(d,d);                 
    Q = G*G';                        %make posdef
    Q = cov2cor(Q);                  %rescale to unit diagonal
    Sigma = Q;
    
    W = randn(r,1);                  %loading vector
    W = W ./sqrt(sum(W.^2));         %rescale to unit norm
    W = W .*((2*rand/3) + (1/3));    %rescale by amount randomly and uniformly chosen in [1/3,1]
    W = [W;zeros(d-r,1)];            %pad with zeros
    
    %Check if sign consistency matches request
    % ||(Q_{J^cJ})*(Q_{JJ}^-1)*sign(W_J)||_inf <= 1
    m = max(abs((Q(r+1:d,1:r)*inv(Q(1:r,1:r))*sign(W(1:r)))));
    isConsistent = m <= 1;
    %done = (consistent == (check <= 1));
    done = ~requireConsistent | (requireConsistent & isConsistent);
    done = done | (iter > maxIter);
    iter = iter + 1;
end

if iter > maxIter
  fprintf('could not make sign consistent data\n')
end

i=0;
model = struct('mu', mu, 'Sigma', Sigma);
while i<nDataSets
    X = gaussSample(model, n);          %now sample rows of X
    %C = (X'*X)./n;
    %Check if sign consistency w.r.t. the empirical cov matrix matches
    %request as well.
    %check = max(abs((C(r+1:d,1:r)*inv(C(1:r,1:r))*sign(W(1:r)))));
    %if(consistent == (check < 1)); 
        y = X*W;                          %use only the relevant features to generate y
        sigma = noise * sqrt(mean(y.^2));   %noise std
        mm = struct('mu', 0, 'Sigma', sigma);
        y = y + gaussSample(mm, n);     %add noise
        i = i+1;
        Xdata{i} = X; ydata{i} = y;  
    %end
end

if(nDataSets == 1)
   Xdata = Xdata{:};
   ydata = ydata{:};
end

end
