function [adj,scores,evals,order,parents,dags] = LassoOrderGreedy(X,maxIter,restartVal,complexityFactor,discrete,clamped,PP,hybrid)
%[adj,scores,evals,order,parents,dags] =
%LassoOrderGreedy(X,maxIter,restartVal,complexityFactor,discrete,clamped,PP,hybrid)
%
% Inputs:
%   X(instance,feature)
%   maxIter - maximum number of family evaluations
%   restartVal - probability of random restart after each step
%   complexityFactor - weight of free parameter term
%     (log(n)/2 == BIC, 1 == AIC)
%   discrete - set to 0 for continuous data, 1 for discrete data,
%     set to 1X for continuous data and searching all subsets up to size X
%     set to -1X for discrete data and searching all subsets up to size X
%   clamped(instance,feature) - 0 if unclamped, 1 if clamped
%   PP(feature1,feature2) - 1 if we consider feature1 to be a parent of
%       feature 2, 0 if this is disallowed
%   hybrid - if set to 1, calls DAGsearch after finding a local min
%          - if set to 2, calls DAGsearch after evaluating on ordering
%          - if set to -1, only searches order-space if at global min
%
% Outputs:
%   adj - adjacency matrix for the highest scoring structure
%   scores - scores after each step
%   evals - number of family evaluations after each step
%   parents - parameters for highest scoring structure
%   dags - adjacency matrices after each step

if nargin < 8
    hybrid = 0;
end

doPlot = 0; % Plot graphs of local/global mins

zeroThreshold = 0;

[n,p] = size(X);
restart = 1;
Gmin_score = inf;
Gmin_startingScore = inf;
evals(1) = 0;
scores(1) = inf;
dags{1} = ones(p);
Ind = 2;

iter = 0;

while evals(end) < maxIter
    drawnow;

    iter = iter + 1;


    if restart == 1
        % Restart Case

        % randomly chose an ordering

        order = randperm(p);

        % compute initial parameters, nll, free parameters, and score
        [parents,graphScores,familyEvals] = OrderSearchDAGEvaluate(X,order,complexityFactor,discrete,clamped,PP);

        % set initial value
        Lmin_score = sum(graphScores);
        Lmin_order = order;
        Lmin_parents = parents;

        % compare to current global min
        if Lmin_score < Gmin_score
            Gmin_score = Lmin_score;
            Gmin_order = order;
            Gmin_parents = parents;
        end

        % Update state indicators
        atLocalMin = 0;
        restart = 0;

        % Update Counters
        evals(Ind) = evals(Ind-1)+1;
        scores(Ind) = inf;
        dags{Ind} = ones(p);
        Ind = Ind+1;
        evals(Ind) = evals(Ind-2) + familyEvals;
        scores(Ind) = sum(graphScores);
        dags{Ind} = sparse(OrderSearchGetAdjacency(order,parents,zeroThreshold));
        Ind = Ind+1;

        % Hybrid == -1 Option, we restart if this isn't the best initial
        %   ordering found so far
        if hybrid == -1
            if Lmin_score < Gmin_startingScore
                % Update the best starting score found so far, and search
                %   starting from this ordering
                Gmin_startingScore = Lmin_score;
            else
                % Otherwise, sample a new ordering
                restart = 1;
            end
        end

    else
        % 1st Iter after Restart Case - Need to evaluate all twiddles
        % (involves solving 2*p Logistic_Lasso problems)

        atLocalMin = 1;

        if restart == 0
            % First iteration after restart: Test All Twiddle Operations
            [params1,params2,new_graphScores,familyEvals] = OrderSearchGetSwapParams(X,order,1:p-1,complexityFactor,discrete,clamped,PP);
        else
            % 2nd+ iteration after restart:
            %   update parameters around previous twiddle operation
            %   (much cheaper)
            [temp_params1,temp_params2,temp_graphScores,familyEvals] = OrderSearchGetSwapParams(X,order,[minInd-1 minInd+1],complexityFactor,discrete,clamped,PP);
            if minInd-1 > 0
                new_graphScores(minInd-1,:) = temp_graphScores(minInd-1,:);
                params1{minInd-1} = temp_params1{minInd-1};
                params2{minInd-1} = temp_params2{minInd-1};
            end
            new_graphScores(minInd,1) = old_graphScores(minInd+1);
            new_graphScores(minInd,2) = old_graphScores(minInd);
            params1{minInd} = old_parents{minInd};
            params2{minInd} = old_parents{minInd+1};
            if minInd+1 < p
                new_graphScores(minInd+1,:) = temp_graphScores(minInd+1,:);
                params1{minInd+1} = temp_params1{minInd+1};
                params2{minInd+1} = temp_params2{minInd+1};
            end
        end

        % Choose Twiddle that results in lowest score
        delta_score = (new_graphScores(:,1)-graphScores(1:p-1)) + ...
            (new_graphScores(:,2) - graphScores(2:p));
        [junk minInd] = min(delta_score);

        % Update order, parents, nll, and free_params
        order = order([1:minInd-1 minInd+1 minInd minInd+2:p]);
        old_graphScores = graphScores;
        graphScores(minInd) = new_graphScores(minInd,1);
        graphScores(minInd+1)=new_graphScores(minInd,2);
        currentScore = sum(graphScores);

        old_parents = parents;
        parents{minInd} = params1{minInd};
        parents{minInd+1} = params2{minInd};
        for ind = minInd+2:p
            parents{ind}([minInd+1 minInd+2]) = parents{ind}([minInd+2 minInd+1]);
            if ind < p
                params1{ind}([minInd+1 minInd+2]) = params1{ind}([minInd+2 minInd+1]);
                params2{ind}([minInd+1 minInd+2]) = params2{ind}([minInd+2 minInd+1]);
            end
        end

        % Check for local/global decrease
        if currentScore < Lmin_score
            Lmin_score = currentScore;
            Lmin_order = order;
            Lmin_parents = parents;
            atLocalMin = 0;

            if Lmin_score < Gmin_score
                Gmin_score = Lmin_score;
                Gmin_order = order;
                Gmin_parents = parents;
            end

        end

        % VERIFICATION CODE - score update
        if 0
            [temp_parents,temp_graphScores] = OrderSearchDAGEvaluate(X,order,complexityFactor,discrete,clamped,PP);
            temp_score = sum(temp_graphScores);
            fprintf('Difference between correct score and maintainted score:\n')
            abs(temp_score - currentScore)
            pause;
        end

        % VERIFICATION CODE - parameter update
        if 0
            [temp_parents,temp_graphScores] = OrderSearchDAGEvaluate(X,order,complexityFactor,discrete,clamped,PP);
            for i = 1:p
                if  sum(abs(parents{i} - temp_parents{i})) > 1e-4
                    fprintf('Lost track of parents:\n');
                    [parents{i} temp_parents{i}]
                    pause;
                end
            end
        end

        % Update state indicator
        restart = -1;

        % Update Counters
        evals(Ind) = evals(Ind-1) + familyEvals;
        scores(Ind) = Lmin_score;
        dags{Ind} = sparse(OrderSearchGetAdjacency(Lmin_order,Lmin_parents,zeroThreshold));
        Ind = Ind+1;


    end

    fprintf('OrderSearch: It %d, Evals = %d, Lmin = %.3f, Gmin = %.3f',iter,evals(end),Lmin_score,Gmin_score);
   drawnow;

    if atLocalMin
        fprintf(' (Found Local Minimum)\n');
        restart = 1;
    elseif restart == 1
        fprintf(' (Restarting)\n');
    elseif restartVal > 0 && rand < restartVal
        fprintf(' (Randomly Restarting)\n');
        restart = 1;
    else
        fprintf('\n');
    end



    drawnow;

    % Based on Hybrid Option, descend in DAG-space to a local min
    if (evals(end) <  maxIter) && ((hybrid == 1 && atLocalMin) || hybrid == 2)

        fprintf('Calling DAGsearch\n');

        % Run DAGsearch to a local min
        [DS_adjMatrix,DS_scores,DS_evals,DS_dags] = DAGsearch(X,maxIter-evals,restartVal,complexityFactor,discrete,clamped,PP,1,OrderSearchGetAdjacency(Lmin_order,Lmin_parents,0));

        % Compare against global min
        Lmin_score = DS_scores(end);

        if Lmin_score < Gmin_score
            Gmin_score = Lmin_score;
            Gmin_order = [];
            Gmin_parents = [];
            Gmin_adj = DS_adjMatrix;
        end

        % Update counters
        DS_it = length(DS_scores)-4; % Ignore first 3 counters
        DS_evals = DS_evals - p; % Don't count evaluating initial DAG
        evals(Ind:Ind+DS_it) = evals(Ind-1) + DS_evals(4:end);
        scores(Ind:Ind+DS_it) = DS_scores(4:end);
        dags(Ind:Ind+DS_it) = DS_dags(4:end);
        Ind = Ind+DS_it+1;

        if hybrid == 2
            restart = 1;
        end
    end

end

order = Gmin_order;
parents = Gmin_parents;
if hybrid == 0
    adj = OrderSearchGetAdjacency(Gmin_order,Gmin_parents,zeroThreshold);
else
    adj = Gmin_adj;
end


end

