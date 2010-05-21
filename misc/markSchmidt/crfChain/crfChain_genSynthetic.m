function [X,y] = crfChain_genSynthetic

nWords = 1000;
nStates = 4;
nFeatures = [2 3 4 5]; % When inputting a data set, this can be set to maximum values in columns of X

% Generate Features (0 means no feature)
for f = 1:length(nFeatures)
    X(:,f) = floor(rand(nWords,1)*(nFeatures(f)+1));
end

% Generate Labels (0 means position between sentences)
y = floor(rand*(nStates+1));
for w = 2:nWords
    pot = zeros(5,1);

    % Features increase the probability of transitioning to their state
    pot(2) = sum(X(w,:)==1);
    pot(3) = 10*sum(X(w,:)==2);
    pot(4) = 100*sum(X(w,:)==3);
    pot(5) = 1000*sum(X(w,:)==4);
    
    % We have at least a 10% chance of staying in the same state
    pot(y(w-1,1)+1) = max(pot(y(w-1,1)+1),max(pot)/10);

    % We have a 5% chance of ending the sentence if last state was 1-3, 10% if
    % last state was 4
    if y(w-1) == 0
        pot(1) = 0;
    elseif y(w-1) == 4
        pot(1) = max(pot)/2;
    else
        pot(1) = max(pot)/10;
    end

    pot = pot/sum(pot);
    y(w,1) = sampleDiscrete(pot)-1;
end