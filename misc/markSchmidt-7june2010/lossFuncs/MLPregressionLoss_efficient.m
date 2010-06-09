function [f,g] = MLPregressionLoss(w,X,y,nHidden)

%Check for improper input
if(any(isnan(w))); f=inf; g=zeros(size(w)); return; end;

%Get number of instances, variables, and layers
[nInstances,nVars] = size(X);
NL = length(nHidden)+1;

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

%Initialize function and gradiant
f = 0;
if nargout > 1
  if(~isempty(nHidden))
    gInput = zeros(size(inputWeights));
  else
    gInput = [];
  end
  gOutput = zeros(size(outputWeights));
  for h = 1:length(nHidden)-1
      gHidden{h} = zeros(size(hiddenWeights{h}));
  end
end

% Compute Output
if(~isempty(nHidden)) 
  ip{1} = X*inputWeights;
  fp{1} = tanh(ip{1});
  ip{1}(:,1) = -inf; %Correct bias unit
  fp{1}(:,1) = 1;    %Correct for bias unit
  for h = 2:length(nHidden)
      ip{h} = fp{h-1}*hiddenWeights{h-1};
      fp{h} = tanh(ip{h});
      ip{h}(:,1) = -inf; %Corect for bias unit
      fp{h}(:,1) = 1;    %Correct for bias unit
  end
  yhat = fp{end}*outputWeights;
else
  yhat = X*outputWeights{1};
end
    
%Compute error matrix
relativeErr = yhat-y;
f = sum(relativeErr(:).^2);

%Compute gradient
if nargout > 1
    err = 2*relativeErr;

    % Output weight gradient 
    gOutput =  fp{end}'*err;

    %If have more than one hidden layer, compute hidden layer weight gradients
    if length(nHidden) > 1

      % Last Layer of Hidden Weights
      backprop = sech(ip{end}).^2.*(err*outputWeights');
      gHidden{end} = fp{end-1}'*backprop;

      % Other Hidden Layer weights
      for h = length(nHidden)-2:-1:1
          backprop =  sech(ip{h+1}).^2.*(backprop*hiddenWeights{h+1}');
          gHidden{h} =  fp{h}'*backprop;
      end

      % Input Weights
      backprop = sech(ip{1}).^2.*(backprop*hiddenWeights{1}');
      gInput   =  X'*backprop;

    elseif length(nHidden==1)

      %If have one hidden layer, compute only input weight gradients
      gInput =  X'*(sech(ip{end}).^2.*(err*outputWeights'));

    end
end
    
% Put Gradient into vector
if nargout > 1
    g = zeros(size(w));
    if(~isempty(nHidden))
      g(1:nVars*nHidden(1)) = gInput(:);
      offset = nVars*nHidden(1);
      for h = 2:length(nHidden)
          g(offset+1:offset+nHidden(h-1)*nHidden(h)) = gHidden{h-1};
          offset = offset+nHidden(h-1)*nHidden(h);
      end
    else
      offset = 0;
    end
    g(offset+1:offset+nHidden(end)) = gOutput;
end

