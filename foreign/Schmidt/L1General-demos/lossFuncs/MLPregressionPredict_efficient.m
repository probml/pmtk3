function [y] = MLPregressionPredict(w,X,nHidden)

[nInstances,nVars] = size(X);

%Extract weights from weight vector
if(~isempty(nHidden))
  inputWeights = reshape(w(1:nVars*nHidden(1)),nVars,nHidden(1));
  offset = nVars*nHidden(1);
  for h = 2:length(nHidden)
    hiddenWeights{h-1} = reshape(w(offset+1:offset+nHidden(h-1)*nHidden(h)),nHidden(h-1),nHidden(h));
    offset = offset+nHidden(h-1)*nHidden(h);
  end
else
  offset = 0;
end
outputWeights = w(offset+1:offset+nHidden(end));

% Compute Output
if(~isempty(nHidden)) 
  ip{1} = X*inputWeights;
  fp{1} = tanh(ip{1});
  ip{1}(:,1) = -inf; %Hidden unit bias
  fp{1}(:,1) = 1; %Hidden unit bias
  for h = 2:length(nHidden)
      ip{h} = fp{h-1}*hiddenWeights{h-1};
      fp{h} = tanh(ip{h});
      ip{h}(:,1) = -inf; %Hidden unit bias
      fp{h}(:,1) = 1; %hidden unit bias
  end
  y  = fp{end}*outputWeights;
else
  y  = X*outputWeights{1};
end

