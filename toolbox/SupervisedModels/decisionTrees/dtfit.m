function root = dtfit(X,y,varargin)
% Fit a simple classification or regression tree. Rows of X represent
% examples, columns are features. Target 'y' can be continuous or
% catagorical, single or multivariate. Automatically infers type:
% classification or regression. Features can be either binary or
% continuous. Continuous features are converted to binary predicates of the
% form p(x) = ( x <= value ) for the value in x that maximizes the
% splitting criteria. Ordinal, numeric, n-ary ( n > 2) features are treated
% as continuous. Does not currently support nominal, n-ary (n > 2)
% features, (i.e. features with no natural ordering.)Currently does not
% handle missing features.
%
% Optional named parameters: 
%   'splitMeasure' (default = 'IG' for binary classification
%                             'GINI' for n-ary classification
%                             'MSE'  for regression
%       'IG'   Information gain
%       'GINI' Gini impurity
%       'MSE'  Mean squared error (also called Least Squares Deviation)
%   
%   'randomFeatures' (default = nfeatures) If set to an integer m, only a
%       random sample of m features is considered for splitting at each 
%       node. The best of these is chosen. If m is larger than the number
%       of available features, then all of the available features are
%       considered. 
%   'maxdepth', (default = nfeatures), The maximum depth of the tree. A
%       value of 0 creates a single node containing all of the examples. 
%   'mingain', (default = 0), Nodes only split if the gain that would be
%       obtained is greater than this value. 
%   'minNodeSize' (default = 1) A node, n, is not split if there are fewer
%       than this number of examples left at n. 
%   'forceRegression' (default = false) If true, a regression tree is created
%       even if the target values look like discrete classes, i.e. all
%       integers. Not usually necessary to specify this value. 
   
    
    [nexamples,nfeatures] = size(X);
    [splitMeasure,randomFeatures, maxdepth,mingain,minNodeSize,forceRegression] = process_options...
        (varargin,'splitMeasure','default','randomFeatures',nfeatures,'maxdepth',nfeatures,'mingain',0,'minNodeSize',1,'forceRegression',false);

    isRegression = isnumeric(y) && ((~all(round(y(:)) == y(:))) || forceRegression); 
    isbinary = featureTypes(X);   %Catagorize each feature as binary or continuous
    warning('off','MATLAB:CELL:UNIQUE:RowsFlagIgnored'); %So that we can treat cells and arrays similarly.
    nclasses = numel(unique(y,'rows')); %Only useful for classification
    if(strcmp(splitMeasure,'default')),splitMeasure = defaultMeasure();end
    root = initializeRoot(); % Start builiding the tree
       
    function root = initializeRoot()
    %Create the tree and begin recursive splitting. 
        root = dectree;
        root.isRegression = isRegression;   % 
        root.examples = (1:nexamples)';     % examples and features are stored 
        root.features = 1:nfeatures;        % at each node as indicies into X
        setyhat(root);                      % This is the predicted output at this point in the tree. 
        partition(root);                    % begin splitting the tree
    end
    
    function partition(node)
    %Recursively partition nodes until one of the base cases is reached.
        if(baseCases1_4(node.examples,node.features));return,end         %Base cases 1-4
        [bestFeature,leftExamples, rightExamples,fork,gain] = selectFeature(node.examples,node.features);
        if(baseCases5_6(leftExamples,rightExamples,gain));return,end     %Base cases 5-6
        node.splitFeature = bestFeature;
        node.fork = fork;                                                %Used to direct test examples through the tree.
        remainingFeatures = setdiff(node.features,bestFeature);
        createNode('left',node,leftExamples,remainingFeatures);            
        createNode('right',node,rightExamples,remainingFeatures);        
    end
    
    function createNode(child,parent,examples,features)
    %Create a child node, attach it to its parent, and partition recursively. 
        node = dectree;
        parent.(child) = node;
        node.isRegression = parent.isRegression;
        node.examples = examples;
        node.features = features;
        setyhat(node);
        partition(node); %recursive call
    end

    function setyhat(node)
    % Set the predicted output for this point in the tree. 
        if(isRegression)
            node.yhat = mean(y(node.examples,:));
        else %classification, so set yhat to majority label
            node.yhat = majority(node.examples);
        end
    end

    function stop = baseCases1_4(examples,features)
    %There are 6 stopping conditions, 1-4 are dealt with here.
    %(1) Too few examples left at this node, (i.e. <= minNodeSize)
    %(2) Maximimum depth reached, (i.e. max number of features used)
    %(3) All of the remaining examples at this node are identical w.r.t.
    %    the features remaining at this node. 
    %(4) The node is pure, that is, the value of y is the same for all
    %    examples at this node.
        stop = false;
        if(numel(examples) <= minNodeSize),stop = true;return,end
        depth = nfeatures - numel(features) + 1;
        if(depth > maxdepth || isempty(features)),stop = true;return,end
        if(numel(unique(X(examples,features),'rows')) == 1),stop = true;return,end 
        if(numel(unique(y(examples,:),'rows')) == 1),stop = true;return,end    
    end

    function stop = baseCases5_6(leftExamples,rightExamples,gain)
    %(5) If the gain, (perhaps information gain, etc) that would be
    %    obtained by splitting is less than mingain.
    %(6) The best split would result in one of the child nodes recieving 0
    %    examples.
       stop = false;
       if(gain < mingain),stop = true;return,end
       if(isempty(leftExamples) || isempty(rightExamples)),stop = true;return,end
    end

    function [bestFeature,leftExamples,rightExamples,fork,improvement] = selectFeature(examples,features)
    % Select the best feature to split on based on the specified remaining
    % examples and features. Also return the examples partitioned according
    % to this feature, a handle to the partitioning function, 'fork', and a
    % measure of the gain that would be obtained if this split were to take
    % place. Split measure used depends on the optional 'splitMeasure'
    % parameter. See defaultMeasure() for defaults.
        features = features(randperm(numel(features)));
        features = features(1:min(randomFeatures,numel(features)));
        parentMeasure = calcMeasure(examples);
        improvement = -1;
        for f=1:numel(features)
           feature = features(f);
           values = unique(X(:,feature));
           if(isbinary(feature)) 
              op = @eq; % == 
           else %continuous
              op = @le; % <=
           end
           subImprovement = -1;  
           for v=1:numel(values) 
                val = values(v);  
                left = examples(op(X(examples,feature),val));
                right = setdiff(examples,left);
                leftMeasure = calcMeasure(left);
                rightMeasure = calcMeasure(right);
                delta = parentMeasure - (numel(left)/numel(examples))*leftMeasure - (numel(right)/numel(examples))*rightMeasure;
                if(delta > subImprovement)
                    subImprovement = delta;
                    bestVal = val;
                    bestLeft = left;
                    bestRight = right;
                end
            end
            if(subImprovement > improvement)
              improvement = subImprovement;
              bestFeature = feature;
              value = bestVal;
              operator = op;
              leftExamples = bestLeft;
              rightExamples = bestRight;
            end
        end
        fork = @(example)operator(example(:,bestFeature),value);
    end
    
    function measure = calcMeasure(examples)
    % Used by selectFeature to calculate the approprite measure by which
    % candidate splits will be evaluated. This is usually called for the
    % examples at a parent node and then again for each set of examples
    % that would be at the child nodes if the candidate split were to
    % occur. The improvement is then calculated by taking the parent value
    % and subtracting off the child values each weighted by the proportion
    % of examples sent to that child. 
    % deltaI = Iparent - Pleft*Ileft - Pright*Iright
        if(isempty(examples)),measure = 0;return,end
        switch splitMeasure
           case 'MSE'  
                measure = mean((y(examples,:) - mean(y(examples,:))).^2);
           case 'IG'
             %http://en.wikipedia.org/wiki/Decision_tree_learning#Information_gain
             counts = normalizedCounts(examples);
             lcounts = log2(counts);
             lcounts(isinf(lcounts)) = 0;
             measure = -sum(counts.*lcounts);
           case 'GINI'
             %http://en.wikipedia.org/wiki/Decision_tree_learning#Gini_impurity
             counts = normalizedCounts(examples);
             measure = 1 - counts*counts';     
        end
            function counts = normalizedCounts(examples)
                [junk,junk,numericLabels] = unique(y(examples,:),'rows');
                counts = hist(numericLabels,nclasses);
                counts = counts ./ sum(counts);
            end
    end

    function splitMeasure = defaultMeasure()
    % Return the default split measure
        if(isRegression)
            splitMeasure = 'MSE';
        else
            if(nclasses == 2)
                splitMeasure = 'IG';
            else
                splitMeasure = 'GINI'; 
            end
        end
    end    
    
    function isbinary = featureTypes(X)
    % Catagorize each feature as binary or not. 
        isbinary = false(1,nfeatures);
        for f = 1:nfeatures
            isbinary(f) = numel(unique(X(:,f))) == 2;
        end
    end

    function label = majority(examples)
    % Return the majority target label of the specified training examples. 
        if(isnumeric(y) || islogical(y))
            label = mode(cast(y(examples,:),'double'),1);          
        else %e.g. cell array
            [b,m,n] = unique(y(examples,:));
            label = b(mode(n));
        end
    end
end %end of file




