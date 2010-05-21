function [PP_AND,PP_OR,evals] = L1MarkovBIC(X,complexityFactor,discrete,clamped,nodeNames,verbose)

if nargin < 6
    verbose = 1;
end

[n,p] = size(X);

PP = zeros(p);
for i = 1:p
    if discrete == 1
        y = sign(X(clamped(:,i)==0,i)-.5);
    else
        y = X(clamped(:,i)==0,i);
    end
    
    if verbose
    tic;
    end
    [params,scores,evals(i)] = OrderSearch_sub(X(clamped(:,i)==0,[1:i-1 i+1:p]),y,complexityFactor,discrete);
    if verbose
        toc
    end
    
    PP([1:i-1 i+1:p],i) = params(2:end) ~= 0;
    
    if verbose
        fprintf('Estimated Markov Blanket of node %d (%s):\n',i,nodeNames{i});
        MB = find(PP(:,i));
        nodeNames(MB)
    end
end
% OR version
PP_OR = sign(PP+PP');
% AND version
PP_AND = PP;
PP_AND((PP~=PP'))=0;
evals = sum(evals);