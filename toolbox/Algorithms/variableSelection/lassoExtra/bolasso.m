function [selectedVars,Wlsq,varargout] = bolasso(X,y,varargin)
% Use the Bolasso (bootstrap-enhanced least absolute shrinkage operator) to
% perform model selection, i.e. to select relevant variables. Once
% selected, fit a model using unregularized least squares regression
% using only the selected variables. 
% 
% This is an implementation of Francis R. Bach's Bolasso algorithm
% described here: www.di.ens.fr/~fbach/icml_bolasso.pdf
%
% X                     an n-by-d matrix whose n rows are the d-dimensional
%                       examples. 
%
% y                     the target or output variable, a column vector. 
%
% OPTIONAL NAMED PARAMETERS
%
% nbootstraps           (default = 128 - appropriate for n ~ 1000)  
%                       the number of bootstrap replicates to use.
%                       Bach calls this parameter, 'm' and uses a value of
%                       128 for figure 2. "Following Proposition 3, log(m)
%                       should be chosen growing with n asymptotically
%                       slower than n." Multiple values can be specified
%                       for nbootstraps in which case the algorithm is run
%                       for each. These must be listed in monotonically
%                       increasing order as in [0,2,4,8,16,32,64,128,256].
%                       A value of 0 indicates that regular lasso should be
%                       performed without any bootstrap resampling. Note
%                       that when multiple values are specified, the
%                       algorithm performs the maximimum listed number of
%                       bootstraps and simply collects interim data for the
%                       rest. 
%
% lambda                the l1 regularizer. 
%                       (default: chosen automatically via the specified
%                       model selection method, from a range of lambdas
%                       chosen automatically within [0, lambda_max]. If
%                       specified, this can be a scalar, or a vector
%                       listing multiple values that will be considered in
%                       place of the automatic range. Automatic lambdas are
%                       listed in order of ascending magnitude.
%
%
% consensusThreshold   (default = 1) An optional parameter between 0 and 1. 
%                       Used in determining which variables to select after
%                       all of the bootstrap replications have been
%                       performed. A value of 0.9, for instance, indicates
%                       that variables that were non-zero in at least 90%
%                       of the replications, should be included. A value of
%                       1, indicates strict intersection. This corresponds
%                       to the Bolasso-S algorithm mentioned in the same
%                       paper. This must be a scalar. 
%
%                       
% modelSelectionMethod  'LCR' | 'CV' | 'BOTH'
%                       (default: 'LCR' if lambda range auto generated,
%                                 'CV'  if lambda range manually specified.
%                       if 'LCR', and returnType = 'best', the
%                       best set of selected variables is determined by
%                       looking for the largest consistent region, i.e. the
%                       largest contiguous range on the regularization path
%                       where the set of selected variables remains the
%                       same. The candidate lambdas must be selected
%                       carefully and it is recommended that they be chosen
%                       automatically, (the default if not specified). LCR
%                       works best when the number of relevant variables,
%                       r, is is much less than d. If you believe this is
%                       not the case, use 'CV' instead.
%
%                       if 'CV', and returnType = 'best', then the best set 
%                       of selected variables is determined by cross
%                       validation on the original data. For each
%                       combination of nbootstraps and lambda,  an
%                       unregularized least squares model is fit to the
%                       training fold using only Xtrain(:,vars) where vars
%                       are the corresponding selected variables given the
%                       lambda and nbootstraps values. 
%
%                       if 'BOTH' and returnType = 'best', then both 'LCR'
%                       and 'CV' are performed as above and the results of
%                       both are returned in selectedVars,Wlsq, bestLambda
%                       and bestNbootstraps. selectedVars is then 1-by-2
%                       cell array, Wlsq is then (d+1)-by-2, bestLambda is
%                       1-by-2 as is bestNbootstraps.
%
% plotResults           (default = true) display a simple plot showing the
%                       selected variables across the regularization path. 
%                       This provides a useful visual check. 
%
%
% ADVANCED PARAMETERS
%
% maxNlambdas           (default = 600) an approximate upper bound on the
%                       number of lambdas to consider, (only used if lambda
%                       is not specified). If this value is less than the
%                       number of critical points determined by lars on
%                       (X,Y), the latter is used instead. Reduce the
%                       default value if you run out of memory. Note that 
%                       since lars efficiently calculates the entire
%                       regularization path, this value has relatively 
%                       little effect on the total running time and in 
%                       practice, a large number of lambdas, (e.g. 600), 
%                       can be considered. Note, this function creates a
%                       temporary matrix requiring
%                       numel(lambda)*max(nbootstraps)*d contiguous bytes
%                       of memory. 
% 
% returnType            'best' | 'all' (default = 'best')
%                       This value alters the return sequence.
%
%                       'best':
%                       [ bestSelectedVars ,...
%                         bestWlsq         ,...
%                         bestLambda       ,...
%                         bestNbootstraps  ,...
%                         allLambdas       ,...
%                         allSelectedVars  ,...
%                         allWlsq           ...
%                       ]                           
%
%                               or
%                       'all':
%                       [allSelectedVars, allWlsq, allLambdas]  
%
%                       Selecting 'all' is faster as further model
%                       selection is not performed. It can be useful for
%                       collecting results for plotting for instance.
%
% 
% larsOptions           a cell array of options to be passed to the lars
%                       algorithm and used instead of the defaults. See
%                       lars.m for documented options: 
%                       lars(X, y, method, stop, useGram, Gram, trace)
%                       By default, lars is called as follows:
%                       lars(X,y,'lasso',0,1,[],0). By specifying 
%                       'larsOptions',{'lasso',0,0} lars is called with
%                       lars(X,y,'lasso',0,0) and will thus not calculate
%                       the gram matrix X'*X, which is slower but takes up
%                       less memory, (useful for very high dimensional
%                       problems). Warning, no check is made by bolasso to
%                       ensure that these are valid parameters. 
%
% CVnfolds              (default = 5) This value is only used if
%                       modelSelectionMethod = 'CV'. It determines the
%                       number of folds to use in the cross validation. 
%
% statusBar            (default = true) true | false
%                      If true, a status bar is displayed showing the
%                      progress of the algorithm. 
%
% OUTPUTS
%
% selectedVars          see returnType
%                       by default, selectedVars is an array holding column
%                       indices into X corresponding to the variables
%                       selected by the bolasso algorithm. If returnType =
%                       'all', then this is a three dimensional logical
%                       matrix such that selectedVars(i,j,k) = true iff 
%                       var j has been selected given lambda(i) after 
%                       nbootstraps(k) bootstraps.
%                       
% Wlsq                  see returnType
%                       this value is only calculated if the number of
%                       output arguments is > 1, (see examples). By
%                       default, Wlsq holds the final weights calculated
%                       via unregularized least squares on the best set of
%                       variables selected by the bolasso algorithm. It is
%                       of size (d+1)-by-1 and includes zero entries and
%                       the the bias term (as the first entry). If
%                       returnType = 'all', this is equivalent to allWlsq, 
%                       (see description below).
%
% allLambdas            all of the lambdas that were considered in model
%                       selection. If these were auto generated, they are 
%                       in ascending order of magnitude. 
%
% ADDITIONAL OUTPUTS:   (only returned when 'returnType' = 'best' (default))
%
% allSelectedVars       a three dimensional logical matrix such that
%                       selectedVars(i,j,k) = true iff var j has been 
%                       selected given lambda(i) after nbootstraps(k) 
%                       bootstraps. 
%
% bestLambda            the value of the l1 regularizer corresponding to
%                       the best set of selected variables, where 'best' is
%                       determined by the specified model selection method.
%                       In the case of LCR, the lambda at roughly at the
%                       center of the largest consistent region is
%                       considered 'best'. If CV was used, 'best'
%                       corresponds to smallest mean squared error.
%                       
% bestNbootstraps       the value of nbootstraps corresponding to the best
%                       set of selected variables, where 'best' is
%                       determined by the specified model selection method.
%
% allWlsq               a cell array so that allWlsq{i,j} holds the weights
%                       calculated using nbootstraps{i},lambda{j}. Only
%                       calculated if requested, (i.e. if the number of
%                       output arguments equals 7).
%
% EXAMPLES:
%
% selectedVars = bolasso(X,y);  %lambdas chosen automatically, returns best
%                               %set of selectedVars as determined by LCR. 
%                               %nbootstraps = 128,consensusThreshold = 1.
%                               %Wlsq not calculated.
%  
% selectedVars = bolasso(X,y,'modelSelectionMethod','BOTH');
%
% [allselectedVars,allWlsq,allLambdas] = bolasso(X,y,'returnType','all');
%
% [bestSelectedVars,bestWlsq,bestLambda,bestNbootstraps,allLambdas,...
%  allSelectedVars,allWlsq] = bolasso(X,y,'plotResults',false);
%
% selectedVars = bolasso(X,y,'nbootstraps',[0,2,4,8,16,32,64,128,256]);
%
% selectedVars = bolasso(X,y,'lambda',0.2);
%
% [selectedVars,Wlsq] = bolasso(X,y,'nbootstraps',512,...
%                      'lambda',exp(-15:1:0),'modelSelectionMethod','CV'...
%                      'CVnfolds',10,'consensusThreshold',0.9,...
%                      'larsOptions',{'lasso',0,0});
%                       
% ALGORITHM:
%
% Let n be the number of examples, (rows) in X
% 
% (1) Sample n examples from (X,y), uniformly and with replacement, call these
%     (Xsamp,ysamp).
% (2) Compute the lasso estimates of the weights W along the full
%     regularization path for (Xsamp,ysamp). (using lars).
% (3) Determine which weights are non-zero given a value of lambda. 
% (4) Repeat steps 1:3, for a specified number of bootstraps 
% (5) Take the intersection of the (indices of the) non-zero weights from
%     all of the bootstrap replications. Select the resulting variables.
%     (See consensusThreshold for possible modification to this step.)
% (6) Refit using the selected variables via unregularized least squares
%     regression, (if requested).
% (7) Repeat for each value of nbootstraps and lambda (actually
%     done more efficiently by gathering interim results).
% (8) determine 'optimal' values for lambda and nbootstraps via either LCR
%     or CV, (see descriptions above), and return the selectedVars 
%     corresponding to these values.
%
% EXTERNAL DEPENDENCIES:
% * lars.m
% * process_options.m
% * Kfold.m (only when cross validation option selected)
% *recoverLambdaFromLarsWeights
%
%
% VERSION: 2008-08-01
%%  Setup 

% This file is from pmtk3.googlecode.com

  
    noutputs = nargout;
    [nbootstraps, lambda     , consensusThreshold, modelSelectionMethod,   ...
     plotResults, maxNlambdas, returnType, larsOptions, CVnfolds,statusBar] = ...
        process_options(varargin,...
        'nbootstraps'           , 128                 ,...
        'lambda'                ,'auto'               ,...
        'consensusThreshold'    , 1                   ,...
        'modelSelectionMethod'  ,'default'            ,...
        'plotResults'           , true                ,...
        'maxNlambdas'           , 600                 ,...
        'returnType'            ,'best'               ,...
        'larsOptions'           ,{'lasso',0,1,[],0}   ,... %i.e. method = 'lasso', earlyStop = false, useGram = true, trace = false
        'CVnfolds'              , 5                   ,...
        'statusBar'             ,true);
    
    if(statusBar), wbar = waitbar(0,'Progress Bar: Initializing Variables...');end
    if(isequal(nbootstraps,0)),plotResults = false; end
    
    [n d] = size(X);                               %n,d used throughout function 
    modelSelectionMethod = setModelSelectionMethod();
    errorCheck();                    
    [Xs ys] = preprocess(X,y);                    
    lambda = autoLambda(Xs,ys,maxNlambdas,lambda); %auto grid lambda, if not specified.
    
    %nzero(i,j,k) = true iff var j is non-zero for lambda(i) in bootstrap k
    nzero = false(numel(lambda),d,nbootstraps(end));
    
    selectedVars = false(numel(lambda),d,numel(nbootstraps)); 
    %similar to nzero except selectedVars(:,:,nbootstraps(k)) represents
    %the intersection across the first k bootstrap replications. 
    
    start = 1;                                     %where to start iterating through nbootstraps
 
%% Special case, 0 bootstraps
    if(nbootstraps(1) == 0)                    %Just do lasso not bolasso
        if(statusBar && ishandle(wbar)),waitbar(0,wbar,'Progress Bar: bootstrap 0, (lasso only)...'); end
        Wfull = lars(Xs,ys,larsOptions{:});
        selectedVars(:,:,1) = nonZeroWeights(Wfull,lambda,Xs,ys);
        start = 2;
    end
 %% Main Loop
    if(statusBar && ishandle(wbar)),waitbar(0.01,wbar,'Progress Bar: beginning main loop...'); end
    bootstrapsDone = 0;                        %number of bootstraps completed so far
    for b=start:numel(nbootstraps)
        while(bootstrapsDone < nbootstraps(b)) %depends on monotonic ordering of nbootstraps
            if(statusBar && ishandle(wbar))
                wtime = 0.01 + (0.8*(bootstrapsDone+1)/max(nbootstraps));
                str = ['Progress Bar: bootstrap ',num2str(bootstrapsDone+1)];
                waitbar(wtime,wbar,str);              
            end
            [Xsamp,ysamp] = sample(X,y);                               
            Wfull = lars(Xsamp, ysamp, larsOptions{:});
            bootstrapsDone = bootstrapsDone + 1;
            %nzero(:,:,bootstrapsDone) = nonZeroWeights(Wfull,lambda,Xsamp,ysamp);  
            Wbig = interpolateLarsWeights(Wfull,lambda,Xsamp,ysamp);
            nzero(:,:,bootstrapsDone) = (Wbig ~= 0);
        end
        %(soft) intersection
        selectedVars(:,:,b) = mean(nzero(:,:,1:bootstrapsDone),3) >= consensusThreshold;
    end
    if(plotResults),
        h = visualize(selectedVars(:,:,b),nbootstraps(b));
    end
%%  Model Selection and Output
    switch returnType
        case 'all'
            if(noutputs > 1)
                if(statusBar && ishandle(wbar)),waitbar(0.9,wbar,'Progress Bar: calculating Wlsq...'); end
                Wlsq = refit(X,y,selectedVars);
            end
            if(noutputs > 2),varargout{1} = lambda;         end
        case 'best'
            if(statusBar && ishandle(wbar)),waitbar(0.85,wbar,'Progress Bar: performing model selection...'); end
            switch upper(modelSelectionMethod)   
                case 'LCR'
                    [bestSelectedVars,bestLambda,bestNbootstraps] = largestConsistentRegion(selectedVars,lambda,nbootstraps);   
                case 'CV'
                    [bestSelectedVars,bestLambda,bestNbootstraps] = crossValidate(Xs,ys,selectedVars,lambda,nbootstraps,CVnfolds);
                case 'BOTH'
                    
                    bestSelectedVars = cell(1,2);bestLambda = zeros(1,2);bestNbootstraps = zeros(1,2); 
                    [bestSelectedVars{1},bestLambda(1),bestNbootstraps(1)] = largestConsistentRegion(selectedVars,lambda,nbootstraps);   
                    [bestSelectedVars{2},bestLambda(2),bestNbootstraps(2)] = crossValidate(Xs,ys,selectedVars,lambda,nbootstraps,CVnfolds);
                    if(statusBar && ishandle(wbar)), fprintf('\nLCR results are listed first, followed by CV results.\n');end
                    
            end
            
            if(noutputs > 1)
                if(strcmpi(modelSelectionMethod,'BOTH'))
                    bestWlsq = zeros(d+1,2);
                    bestWlsq([1,bestSelectedVars{1}+1],1) = [ones(size(X,1),1),X(:,bestSelectedVars{1})]\y;
                    bestWlsq([1,bestSelectedVars{2}+1],2) = [ones(size(X,1),1),X(:,bestSelectedVars{2})]\y;
                else
                    bestWlsq = zeros(d+1,1);
                    bestWlsq([1,bestSelectedVars+1],1) = [ones(size(X,1),1),X(:,bestSelectedVars)]\y;
                end
            end
            if(noutputs > 5), allSelectedVars = selectedVars;       end
            if(noutputs > 6),
                if(statusBar && ishandle(wbar)),waitbar(0.95,wbar,'Progress Bar: calculating Wlsq...'); end
                allWlsq =  refit(X,y,allSelectedVars); 
            end 
            selectedVars = bestSelectedVars;                      %output 1
            if(noutputs > 1), Wlsq         = bestWlsq;        end %output 2   
            if(noutputs > 2), varargout{1} = bestLambda;      end %output 3
            if(noutputs > 3), varargout{2} = bestNbootstraps; end %output 4         
            if(noutputs > 4), varargout{3} = lambda;          end %output 5
            if(noutputs > 5), varargout{4} = allSelectedVars; end %output 6
            if(noutputs > 6), varargout{5} = allWlsq;         end %output 7 
    end
    if(statusBar && ishandle(wbar))
        waitbar(1,wbar,'Progress Bar: done');
        close(wbar);
    end
%%
    function [Xsamp,ysamp] = sample(Xs,ys)
    %Sample n rows from (Xs,ys) uniformly and with replacement, where n is
    %the number of rows in X, (i.e. Xsamp is the same size as X).
        ndx = floor(n*rand(n,1) + 1);
        [Xsamp,ysamp] = preprocess(Xs(ndx,:),ys(ndx,:)); %standardize for lars
    end
 
%%
    function nzeroPage = nonZeroWeights(Wfull,lambda,Xsamp,ysamp)
    %Return a logical matrix of size numel(lambda)-by-d such that entry
    %nzero(i,j) = true iff the weight associated with dimension j is
    %non-zero given l1 regularizer lambda(i).
    Wbig = interpolateLarsWeights(Wfull,lambda,Xsamp,ysamp);
    nzeroPage = (Wbig ~= 0);
    end

   
%%
    function Wlsq = refit(X,y,selectedVars)
    %Finally refit via unregularized least squares regression using only
    %the variables selected by the bolasso algorithm. 
        [nlambdas,dims,nboots] = size(selectedVars);
        Wlsq = cell(nboots,nlambdas);
        for i=1:nboots
            for j=1:nlambdas
                vars = find(selectedVars(j,:,i));
                W = zeros(dims+1,1);
                W([1,vars+1],1) = [ones(size(X,1),1),X(:,vars)]\y;
                Wlsq{i,j} = W;
            end 
        end
    end
%%
    function [Xs ys] = preprocess(X,y)
    %standardize each column,(variable) of X so that each has 0 mean and
    %unit norm; also center y. This is in preparation for the lars algorithm.
    
        %Same preprocessing as in lars_test.m only slightly more efficient
        %using bsxfun
        Xs = bsxfun(@minus,X,mean(X));            
        Xs = bsxfun(@rdivide,Xs,sqrt(sum(Xs.^2))); 
        ys = bsxfun(@minus,y,mean(y));             
        
    end
%%
    function lambda = autoLambda(Xs,ys,maxNlambdas,lambda)
    % Auto-generate a range of lambdas to search. This is done by
    % attempting to discover the distribution of lambdas, by performing
    % lars on (Xs,ys) as well as on resampled data, and then inserting new 
    % values half way between consecutive pairs of existing lambdas until
    % approximately maxNlambdas have been selected. 
        
        if(~strcmpi(lambda,'auto'))
            if(size(lambda,1) > size(lambda,2))
                lambda = lambda'; %make sure its a column vector.  
            end
            return;
        end
        lambda = recoverLambdaFromLarsWeights(Xs,ys,lars(Xs,ys,larsOptions{:}));
        k = numel(lambda);
        while numel(lambda) < ((maxNlambdas/4) - k); % /4 so that we can double twice via interpolation
            [Xsamp,ysamp] = sample(Xs,ys);
            lambda = [lambda, recoverLambdaFromLarsWeights(Xsamp,ysamp,lars(Xsamp,ysamp,larsOptions{:}))];
        end
        lambda = unique(lambda);
        while numel(lambda) < (maxNlambdas/2)
           lambda = sort([lambda,filter([0.5,0.5],1,lambda)]); %filter([0.5,0.5],1,lambda) returns points half way between consecutive lambdas
        end
        lambda = [0,unique(lambda)];
    end


%%
    function [bestSelectedVars,bestLambda,bestNbootstraps] = largestConsistentRegion(selectedVars,lambda,nbootstraps)
    % Select the final variables by looking for the largest consistent
    % region on the regularization path, i.e. the largest contiguous region
    % in which the selected variables do not change. This function is
    % highly sensitive to the choice of candidate lambdas and will work best
    % when the lambdas are automatically generated via the autoLambda
    % function above. 
        
        maxcount = 0;
        lambdaLeftNDX = 0; lambdaRightNDX = 0;
        nbootstrapsNDX = []; 
        bestVars = [];
        for b = 1:numel(nbootstraps)
           currentVars = selectedVars(1,:,b);
           currentCount = 1;
           for lam=2:numel(lambda)
               if(isequal(selectedVars(lam,:,b),currentVars))
                  currentCount = currentCount + 1; 
               else
                   if(currentCount > maxcount)
                        updateCounts;
                   end
                   currentVars = selectedVars(lam,:,b);
                   currentCount = 1;
               end
               if(currentCount > maxcount)
                   updateCounts;
               end
           end 
        end
        allvars = 1:d;
        bestSelectedVars = allvars(bestVars);
        bestLambda = lambda(ceil((lambdaRightNDX+lambdaLeftNDX) /2));
        bestNbootstraps = nbootstraps(nbootstrapsNDX);
        if((maxcount / numel(lambda)) < 0.05)
            warning('BOLASSO:lcrWarning',['Only ',num2str(maxcount),'/',num2str(numel(lambda)),' of the specified lambdas lie within the largest consistent region of the regularization path. Cross validation may provide a better estimate.']);
        end
            function updateCounts
            %helper sub-function to largestConsistentRegion
                maxcount = currentCount;
                bestVars = currentVars;
                lambdaRightNDX = lam;
                lambdaLeftNDX = lambdaRightNDX - maxcount;
                nbootstrapsNDX = b;
            end
        if(plotResults)
            clf(h);
            visualize(selectedVars(:,:,end),bestNbootstraps,lambdaLeftNDX,lambdaRightNDX,h);
            hold on;
        end
    
    end %end of largestConsistentRegion()

%%
    function [bestSelectedVars,bestLambda,bestNbootstraps] = crossValidate(X,y,selectedVars,lambda,nbootstraps,CVnfolds)
    %Perform model selection via cross validation. Candidate models
    %constitute the selected variables corresponding to each value of
    %lambda and each value of nbootstraps. Models are trained on training
    %sets via unregularized least squares regression using only the
    %selected vars corresponding to the the lambda and nbootstrap values
    %under examination. 
        allvars = 1:d;
        [trainfolds, testfolds] = Kfold(n, CVnfolds,1);
        errors = zeros(numel(nbootstraps),numel(lambda),n);
        X = [ones(size(X,1),1),X];
        for f=1:CVnfolds
            Xtrain = X(trainfolds{f},:); ytrain = y(trainfolds{f},:);
            Xtest = X(testfolds{f},:);   ytest = y(testfolds{f},:);
            for b = numel(nbootstraps)
               for lam=1:numel(lambda) 
                  vars = [1,allvars(selectedVars(lam,:,b))+1];
                  Wlsq = zeros(d+1,1);
                  Wlsq(vars,1) = Xtrain(:,vars)\ytrain;
                  yhat =  Xtest*Wlsq;
                  errors(b,lam,testfolds{f}) = sum((yhat-ytest).^2,2);
               end
            end
        end
        errMean = mean(errors,3);
        [val,best] = min(errMean(:));
        [bsBestNDX,lamBestNDX] = ind2sub(size(errMean),best);
        bestSelectedVars = allvars(selectedVars(lamBestNDX,:,bsBestNDX));
        bestLambda = lambda(lamBestNDX);
        bestNbootstraps = nbootstraps(bsBestNDX);
    end

%%
    function method = setModelSelectionMethod()
    %Options are either CV for cross validation or LCR for largest
    %consistant region, or 'BOTH'
        if(strcmpi(modelSelectionMethod,'default'))
           if(~isequal('auto',lambda))
              method = 'CV'; 
           else
              method = 'LCR';
           end
        else
            method = modelSelectionMethod;
            if(not(exist('Kfold','file'))&& (strcmpi(method,'CV') || strcmpi(method,'BOTH')))
                method = 'LCR';
                warning('BOLASSO:cvWarning','Could not find Kfold.m, which is required by the ''CV'' option - switching to ''LCR''.');
            end
        end
    end

%%
    function errorCheck()
    %Check for certain input errors. 
        if(not(exist('lars','file')))
            error('Requires lars.m available at http://www2.imm.dtu.dk/pubdb/views/publication_details.php?id=3897');
        end
        
        if(~isequal(nbootstraps,sort(nbootstraps)) || ~all(nbootstraps >= 0))
            error('nbootstraps must be >= 0 and listed in ascending order.');
        end
        
        ct = consensusThreshold;
        if(~isscalar(ct) || ct < 0 || ct > 1)
           error('consensusThreshold must be a scalar between 0 and 1, inclusive.'); 
        end
        
        if(~isequal(size(y),[n,1]))
           error('y must be a column vector of size n-by-1'); 
        end
        
        if(~ismember(lower(returnType),{'best','all'}))
            error('returnType must be one of ''best'' | ''all'' .');
        end
        
        if(~ismember(upper(modelSelectionMethod),{'LCR','CV','BOTH'}))
           error('modelSelectionMethod must be one of ''LCR'' | ''CV'' | ''BOTH''.'); 
        end
        
        if(~all(lambda >= 0))
            error('all values for lambda must be >= 0.');
        end
        
        if(noutputs > 3 && strcmpi(returnType,'all'))
           error('Too many outputs: specify 3 or fewer when returnType = ''all'''); 
        end
        
        if(~strcmpi(lambda,'auto') && maxNlambdas ~= 600)
            warning('BOLASSO:inputWarning','maxNlambdas is ignored when lambda is specified');
        end
        
        if(strcmpi(modelSelectionMethod,'LCR') && CVnfolds ~= 5)
           warning('BOLASSO:inputWarning','CVnfolds is ignored when modelSelectionMethod is not ''CV'' .'); 
        end
        
        if(strcmpi(modelSelectionMethod,'LCR') && ~strcmpi(lambda,'auto'))
           warning('BOLASSO:lcrWarning','LCR works best when the lambdas are automatically selected, not manually specified: use with caution or switch to ''CV''.'); 
        end
        
        
    end

%%
    function h = visualize(selectedVarsPage,bootstraps,left,right,h)
    %Visualize the selected variables and optionally, the largest
    %consistent region.
          if(nbootstraps == 0)
             fprintf('Sorry, cannot visualize, when nbootstraps = 0\n');
             h = 0;
             return; 
          end
          if(nargin == 5)
              figure(h);
          else
              figure;
              hold on;
          end
          spy(selectedVarsPage');
          set(gca,'plotBoxAspectRatioMode','auto','YTick',2:2:d,'FontSize',12);
          set(gca,'XLim',[1,size(selectedVarsPage,1)]);
          xlabel('lambda index');
          ylabel('variable index');
          title(['selected variables after ',num2str(bootstraps), ' bootstraps']);
          if(nargin > 3)
             hold on;
             a = axis;
             plot([left,left],[a(3),a(4)],'--r');
             plot([right,right],[a(3),a(4)],'--r');
          end
          h = gcf;
    end
end %end of bolasso
