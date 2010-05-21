function [X] = L1precisionBCD(sigma_emp,lambda)

if nargin < 3
    useQP = 1;
end

verbose = 1;
optTol = 0.00001;
S = sigma_emp;
p = size(S,1);
row = lambda;
maxIter = 10;
A = [eye(p-1,p-1);-eye(p-1,p-1)];
f = zeros(p-1,1);

% Initial W
W = S + row*eye(p,p);

% Check for qp mex file
if exist('qpas') == 3 && ~strcmp(version,'7.5.0.342 (R2007b)')
    useQP = 1;
    qpSolver = @qpas;
    qpArgs = {[],[],[],[]};
elseif 1
    useQP = 0;
else
    useQP = 1;
    qpSolver = @quadprog;
    options = optimset('LargeScale','off','Display','none');
    qpArgs = {[],[],[],[],[],options};
end

for iter = 1:maxIter

    % Check Primal-Dual gap
    X = W^-1; % W should be PD
    gap = trace(S*X) + row*sum(sum(abs(X))) - p;
    fprintf('Iter = %d, OptCond = %.5f\n',iter,gap);
    if gap < optTol
        fprintf('Solution Found\n');
        break;
    end

    for i = 1:p

        if verbose
            X = W^-1; % W should be PD
            gap = trace(S*X) + row*sum(sum(abs(X))) - p;
            fprintf('Column = %d, OptCond = %.5f\n',i,gap);
            if gap < optTol
                fprintf('Solution Found\n');
                break;
            end
        end

        % Compute Needed Partitions of W and S
        s_12 = S(mysetdiff(1:p,i),i);
        
        if useQP
            % Solve as QP
            H = 2*W(mysetdiff(1:p,i),mysetdiff(1:p,i))^-1;
            b = row*ones(2*(p-1),1) + [s_12;-s_12];
            w = qpSolver((H+H')/2,f,A,b,qpArgs{:});
        else
            % Solve with Shooting
            W_11 = W(mysetdiff(1:p,i),mysetdiff(1:p,i));
            Xsub = sqrtm(W_11);
            ysub = Xsub\s_12;
            w = W_11*LassoShooting(Xsub,ysub,2*row,'verbose',0);
        end

        % Un-Permute
        W(mysetdiff(1:p,i),i) = w;
        W(i,mysetdiff(1:p,i)) = w';
    end
    %drawnow
end