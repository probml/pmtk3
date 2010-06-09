function [PP_AND,PP_OR,evals] = L1MarkovBIC(X,complexityFactor,discrete,clamped,nodeNames,blockSize,verbose)
% Incremental version of L1MB, where blocks of size blockSize
%   are first used to eliminate potential parents,
%   then the remaining parents are used in the full regression

if nargin < 7
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
    Xc = X(clamped(:,i)==0,[1:i-1 i+1:p]);
    evals(i) = 0;

    if verbose
    tic
    end
    parents = zeros(p-1,1);
    for blockStart = 1:blockSize:p-1
        if blockStart+blockSize > p-1
            blockEnd = p-1;
        else
            blockEnd = blockStart+blockSize-1;
        end
        if verbose
            fprintf('Processing Block from %d to %d\n',blockStart,blockEnd);
        end
        [params,scores,evals_sub] = OrderSearch_sub(Xc(:,blockStart:blockEnd),y,complexityFactor,discrete);
        parents(blockStart:blockEnd) = params(2:end) ~= 0;
        evals(i) = evals(i) + evals_sub;
    end
    if verbose
        fprintf('Parents removed by blocking: %d\n',sum(parents==0));
    end

    if 0% Regression on full set
        [params] = OrderSearch_sub(X(clamped(:,i)==0,[1:i-1 i+1:p]),y,complexityFactor,discrete);
    else
        % Regression on reduced set
        [blockParams,scores,evals_sub] = OrderSearch_sub(Xc(:,find(parents)),y,complexityFactor,discrete);
        params = zeros(p,1);
        params(1+find(parents)) = blockParams(2:end);
        evals(i) = evals(i) + evals_sub;
    end
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