function [w,wp,it] = LassoLARS(X, y, t,varargin)
% This function computes the Least Squares parameters
% whose 1-Norm is less than t
%
% Method used:
%   Least Angle Regression (Efron et al.)
%
% Note:
%   Substantial portions of this code are from Karl Skoglund's implementation:
%   http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=3897

[maxIter,verbose,optTol,zeroThreshold] = process_options(varargin,'maxIter',10000,'verbose',2,'optTol',1e-5,'zeroThreshold',1e-4);
[n p] = size(X);

% Start at zero w/ no variables in active set
vars = 0;
nvars = min(n-1,p);
beta = zeros(p,1);
A = [];
I = 1:p;
mu = zeros(n,1);
R = [];
k = 0;
lassocond = 0;

if verbose==2
    fprintf('%5s %6s %15s %15s %15s\n','Step','Active','norm(step)','f(beta)','norm(beta)');
    it=1;
    wp = beta;
end

Xy = X'*y;
while vars < nvars & k < maxIter
    k = k + 1;
    % compute correlations
    c = Xy - X'*mu;

    % compute element to add to active set
    [C maxInd] = max(abs(c(I)));
    j = I(maxInd);

    if ~lassocond
        % update active set
        R = cholinsert(R,X(:,j),X(:,A));
        A = [A j];
        I(I == j) = [];
        vars = vars + 1;
    end

    % signs of correlations
    s = sign(c(A));

    GA1 = R \ (R' \s); 
    AA = 1/sqrt(sum(GA1.*s));
    w = AA*GA1; % weights applied to get equiangular direction
    u = X(:,A)*w; % equiangular direction

    % Least Squares solution when all variables active
    if vars == nvars;
        gamma = C/AA;
    else
        a = X'*u;
        temp = [(C - c(I))./(AA - a(I)); (C + c(I))./(AA + a(I))];
        gamma = min([temp(temp > 0); C/AA]);
    end

    % Lasso Modification

    lassocond = 0;
    temp = -beta(A)./w;
    [gamma_tilde] = min([temp(temp > 0)' gamma]);
    j = find(temp == gamma_tilde);
    if gamma_tilde < gamma,
        gamma = gamma_tilde;
        lassocond = 1;
    end

    % Take step and update weights
    mu = mu + gamma*u;
    beta_old = beta;
    beta(A) = beta(A) + gamma*w;

    % Termination test
    t2 = sum(abs(beta));
    if t2 >= t
        t1 = sum(abs(beta_old));
        s = (t - t1)/(t2 - t1);
        beta = beta_old + s*(beta - beta_old);
        if verbose==2
            fprintf('%5d %6d %15.2e %15.2e %15.2e\n',k,length(A),sum(abs(beta-beta_old)),sum((X*beta-y).^2),sum(abs(beta)));
            it=it+1;
            wp(:,it) = beta;
        end
        break;
    end

    if verbose==2
        fprintf('%5d %6d %15.2e %15.2e %15.2e\n',k,length(A),sum(abs(beta-beta_old)),sum((X*beta-y).^2),sum(abs(beta)));
        it=it+1;
        wp(:,it) = beta;
    end

    % If Lasso condition satisfied, drop variable from active set
    if lassocond == 1
        R = choldelete(R,j);
        I = [I A(j)];
        A(j) = [];
        vars = vars - 1;
    end

end

if verbose
    fprintf('Finished\n');
end
w = beta;

end

%% Fast Cholesky insert and remove functions
% Updates R in a Cholesky factorization R'R = X'X of a data matrix X. R is
% the current R matrix to be updated. x is a column vector representing the
% variable to be added and X is the data matrix containing the currently
% active variables (not including x).
function R = cholinsert(R, x, X)
diag_k = x'*x; % diagonal element k in X'X matrix
if isempty(R)
    R = sqrt(diag_k);
else
    col_k = x'*X; % elements of column k in X'X matrix
    R_k = R'\col_k'; % R'R_k = (X'X)_k, solve for R_k
    R_kk = sqrt(diag_k - R_k'*R_k); % norm(x'x) = norm(R'*R), find last element by exclusion
    R = [R R_k; [zeros(1,size(R,2)) R_kk]]; % update R
end
end

% Deletes a variable from the X'X matrix in a Cholesky factorisation R'R =
% X'X. Returns the downdated R. This function is just a stripped version of
% Matlab's qrdelete.
function R = choldelete(R,j)
R(:,j) = []; % remove column j
n = size(R,2);
for k = j:n
    p = k:k+1;
    [G,R(p,k)] = planerot(R(p,k)); % remove extra element in column
    if k < n
        R(p,k+1:n) = G*R(p,k+1:n); % adjust rest of row
    end
end
R(end,:) = []; % remove zero'ed out row
end
