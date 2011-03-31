function [X,R,params] = efa_prepare_data(data, params);
% difference from mixed_mf_prepare_Data(): added nClass as input

  [Md,Nd] = size(data.discrete);
  [Dc,Nc] = size(data.continuous);

  N = max(Nd,Nc);
  params.N  = N;

  % continuous data
  if Dc>0
    X.c = data.continuous';
    R.c = ~isnan(X.c);
    X.c(~R.c) = 0;
  end
  D.c.beta = [nan,Dc];
  D.c.sigma = [1,Dc]; 

  % discrete data
  if(Md>0)
    nClass  = params.nClass;
    states  = nClass; % modified by emt
    multInd = find(states>2);
    binInd  = find(states<=2);

    if(length(binInd)>0)
      X.b        = data.discrete(binInd,:)';  
      X.b        = X.b - 1; %Recode binary to 0/1
      R.b        = ~isnan(X.b);
      X.b(~R.b)  = 0;
      D.b.beta   = [nan,length(binInd)];
    end   
 
    if(length(multInd)>0)
      mStates  = nClass(multInd); 
      T  = sum(mStates);
      mMap     = zeros(1,sum(T,1)); 

      X.m = encodeDataOneOfM(data.discrete(multInd,:), mStates, 'M')';
      R.m = ~isnan(X.m);
      X.m(~R.m) = 0;

      for m = 1:length(mStates)
	mMap(sum(mStates(1:m-1))+(1:mStates(m))) = m;
	%mMap(sum(mStates(1:m-1))+1:sum(mStates(1:m))) = m;
      end
 
      D.m.beta = [nan,T];
      params.mMap = mMap;
      params.mStates = mStates;
    end
  end

  params.D=D;
