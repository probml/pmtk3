function [P,W,m,nmax] = ggmLassoHtf(S, lambda, varargin)
% Estimate structure of GGM precision matrix using the "GLASSO" method
% See Hastie, Tibshirani & Friedman ("Elements" book, 2nd Ed, 2008, p637)
%
% Solves: P = argmax  log(det(P)) - Trace(S*P)  -  lambda * ||P||_1
%
% [P, W, Nouter, MaxInner] = glasso(S, lambda, Winit);
%
% S is p-by-p covariance matrix and lambda is the scalar regularization.
% If the 2nd argument lambda is a p-by-p logical array instead 
% then it is the graph adjacency matrix (known sparse edge pattern).
% The 3rd argument (optional) is for warm-starting the initial cov W.
%
% Output P is the sparse precision matrix, W is its inverse (cov),
% Nouter is # of outer loop iterations used (based on 1e-4 tolerance)
% MaxInner is the max # of inner cycle iteratios (pathwise cood descent) 

% This file is from pmtk3.googlecode.com


%PMTKauthor Baback Moghaddam    
%PMTKemail baback@jpl.nasa.gov
%PMTKdate February 7, 2009

% graph has p nodes
p = length(S); 
Noff = p*(p-1)/2;  % # of offdiag elements

[W, MaxOuter, MaxInner, verbose, mytol] = process_options(varargin, ...
  'W', S + lambda*eye(p), 'MaxOuter', 20, 'MaxInner', 20, ...
  'verbose', true, 'mytol', 1e-4); 


% max # iterations for innter/outer loops    
%MaxOuter = 1e4; MaxInner = 1e4; % same as their R code
%mytol = 1e-4;  % same as their R code

% average abs offdiag of cov
Smag = sum(sum(abs(triu(S))))/Noff; 
dW = Inf;

% pre-allocate 
B = zeros(p-1,1);
P = zeros(p);

nmax = 0;
m = 1;
while (m <= MaxOuter) && (dW > mytol)
    
    W0 = W;
    for i = 1:p
        % block 1  (block 2 = i)
        noti = [1:i-1 i+1:p];
        % partition W & S for i
        W11 = W(noti,noti);
        w12 = W(noti,i);
        s22 = S(i,i);
        s12 = S(noti,i);
        w22 = W(i,i);
        
        % if graph is known       
        %    idx = find(G(noti,i));  % W11 non-zeros in G11
        %   B(:) = 0;
        %    B(idx) = W11(idx,idx) \ s12(idx);
                    
        % modified Lasso subproblems using pathwise coord descent
        V = W11;
        B(:) = 0;
        dB = Inf;
        n = 1;
        while (n <= MaxInner) && (dB > mytol)
          B0 = B;
          for j = 1:p-1
            notj = [1:j-1 j+1:p-1];
            res = s12(j) - V(notj,j)'*B(notj);
            B(j) = sign(res)*max([abs(res)-lambda 0])/V(j,j); % soft threshold
          end
          dB = mean(abs(B-B0))/(mean(abs(B0)) + 1e-16);
          n = n + 1;
        end
        % keep track of max # of inner iters
        if n > nmax, nmax = n; end
               
        % update W   
        w12 = W11 * B; 
        W(noti,i) = w12 ;
        W(i,noti) = w12';
        
        % update P
        p22 = max([0  1/(w22 - w12'*B)]);  % must be non-neg
        p12 = -B * p22;
        P(noti,i) = p12 ; 
        P(i,noti) = p12';
        P(i,i) = p22;
        
    end % for i  
    
    % update outer loop count & dW change
    m = m + 1;
    % average abs change in W relative to S
    dW = (sum(sum(abs(triu(W)-triu(W0))))/Noff) / Smag;
    
end



end
