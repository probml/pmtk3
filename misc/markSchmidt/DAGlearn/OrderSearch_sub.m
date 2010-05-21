function [w,graphScore,evals,selectedT] = LassoOrderDAGsub(X,y,complexityFactor,mode)
% Subroutine that does variable selection
%
% Mode:
%   1 = Discrete w/ IRLS-LARS
%   0 = Continuous w/ LARS
%   1K = Continuous w/ Least Squares on all subsets up to size K
%   -1K = Discrete w/ IRLS on all subsets up to size K
[n,p] = size(X);

if mode == 0
    % Continuous: LARS
    if p > 0
        % Compute sufficient statistics
        XX = X'*X;
        Xy = X'*y;
        yy = y'*y;

        % Compute regularization path
        method = 'lasso';stop = 0;usegram = 1;gram = XX;trace = 0;
        wPath = lars(X,y,method,stop,usegram,gram,trace)';

        % Evaluate each subset along the regularization path
        %   (could do this more efficiently within the lars algorithm)
        for i = 1:size(wPath,2)
            w = wPath(:,i);
            nz = w ~= 0;
            w(nz) = XX(nz,nz)\Xy(nz);
            s(i) = score(GLoss(XX,Xy,yy,w),sum(wPath(:,i)~=0),complexityFactor);
        end
        [graphScore minPos] = min(s);
        w = wPath(:,minPos);
        selectedT = sum(abs(w));
        nz = w ~= 0;
        w(nz) = XX(nz,nz)\Xy(nz); % This could be avoided by keeping all results from the loop above
        w = [0;w];
        evals = size(wPath,2);
    else
        w = 0;
        evals = 1;
        selectedT = 0;
        graphScore=score(GLoss(n,sum(y),y'*y,w),0,complexityFactor);
    end
elseif mode > 10
    % Least Squares on all Subsets
    k = mode-10;

    % Compute Sufficient Statistics Once
    XX = X'*X;
    Xy = X'*y;
    yy = y'*y;

    % Evaluate all Subsets
    sets = mysubsets(1:p,k);
    sets{:}
    pause;
    for i = 1:length(sets)
        w = zeros(p,1);
        w(sets{i}) = XX(sets{i},sets{i})\Xy(sets{i});
        s(i) = score(GLoss(XX,Xy,yy,w),sum(w~=0),complexityFactor);
    end
    [graphScore minPos] = min(s);
    w = zeros(p,1);
    w(sets{minPos}) = XX(sets{minPos},sets{minPos})\Xy(sets{minPos});
    w = [0;w];
    evals = length(sets);
elseif mode == 1
    
    % Discrete: IRLS-LARS
    X = [ones(n,1) X];

        options.verbose = 0;
        
        % Compute Max Likelihood solution w/ just bias
    wML = L2LogReg_IRLS(X(:,1),y);
    
    % Compute Derivative at 0
    w = zeros(p+1,1);
    w(1) = wML;
    [junk,g0] = LLoss(w,X,y);
    maxLambda = max(abs(g0));

    % Compute Active Set and score w/ active set
    activeSet = (abs(w) > 1e-4);
    activeSet(1) = 1;
    minGraphScore = score(LLoss(wML,X(:,activeSet),y),sum(abs(wML) > 1e-4),complexityFactor);
    minActiveSet = activeSet;
    minWml = wML;
    selectedT = maxLambda;
    evals = 1;

    % Compute intermediate values along the path
    increment = maxLambda/(p+1);
    for lambda = maxLambda-increment:-increment:0

        %fprintf('Evaluating path value %.5f\n',lambda);
        
        if lambda > 1
         options.order = 3; % Change to -1 for L-BFGS version
        else
           options.order = -1;
        end

        % Compute Next Point on Regularization Path
        w = L1GeneralProjection(@LLoss,w,[0;max(lambda,0)*ones(p,1)],options,X,y);
        w(abs(w) <= 1e-4) = 0;

        % Check if active set has changed
        oldActiveSet = activeSet;
        activeSet = (abs(w) > 1e-4);
        activeSet(1) = 1;
        if sum(abs(activeSet-oldActiveSet)) > 0
            %fprintf('Active Set Changed\n');
            % Compute score w/ updated active set
            wML = L2LogReg_IRLS(X(:,find(activeSet)),y);
            graphScore = score(LLoss(wML,X(:,activeSet),y),sum(abs(wML) > 1e-4),complexityFactor);
            evals = evals + 1;
            if graphScore <= minGraphScore
                minGraphScore = graphScore;
                minActiveSet = activeSet;
                minWml = wML;
                selectedT = lambda;
                %fprintf('New Best!\n');
            end
        end
    end
    w = zeros(p+1,1);
    w(find(minActiveSet)) = minWml;
    graphScore = minGraphScore;
elseif mode < -10
    % Logistic Regression on all Subsets
    k = -(mode+10);
    % Evaluate all Subsets
    %fprintf('p = %d, k = %d\n',p,k);
    sets = mysubsets(1:p,k);
    %fprintf('Length(sets) = %d\n',length(sets));
    for i = 1:length(sets)
        %fprintf('Evaluating Subset %d\n',i);
        w = L2LogReg_IRLS([ones(n,1) X(:,sets{i})],y);
        s(i) = score(LLoss(w,[ones(n,1) X(:,sets{i})],y),sum(abs(w)>1e-4),complexityFactor);
    end
    [graphScore minPos] = min(s);
    w = zeros(p+1,1);
    w([1 1+sets{minPos}]) = L2LogReg_IRLS([ones(n,1) X(:,sets{minPos})],y);
    evals = length(sets);
end

end

function [sets] = mysubsets(n,k)
% Finds all subsets of n up to k
sets{1} = [];
ind = 2;
for i = 1:k
    tmp = subsets1(n,i);
    for j = 1:length(tmp)
        sets{ind} = tmp{j};
        ind = ind+1;

        if length(sets) > 10000
            break;
        end
    end
    %fprintf('len(sets) = %d\n',length(sets));
end
end