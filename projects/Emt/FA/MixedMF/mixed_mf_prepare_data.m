function [Xb,Xm,Xc,params] = mixed_mf_prepare_data(data);


  [Md,N] = size(data.discrete);
  [Mc,N] = size(data.continuous);
  
  Xc = data.continuous';

  if(Md>0)
    states  = max(data.discrete,[],2);
    multInd = find(states>2);
    binInd  = find(states<=2);
    Mm      = length(multInd);
    Mb      = length(binInd);
    Xb      = data.discrete(binInd,:)';  
    Xb      = Xb - 1; %Recode binary to 0/1

    mStates  = states(multInd); 
    Xm       = zeros(N,sum(states(multInd)));
    Rm       = isnan(data.discrete(multInd,:))'; %Get indices of missing multinomial values
    data.discrete(isnan(data.discrete))=1;       %Recode values as 1's to use sparse- will chnage back below
    mMap     = zeros(sum(states(multInd)),1); 
    mStatesMap = [];
    for m = 1:Mm
      Xm(:,sum(mStates(1:m-1))+(1:mStates(m))) = full(sparse(1:N,data.discrete(multInd(m),:),ones(N,1)));
      mMap(sum(mStates(1:m-1))+(1:mStates(m))) = m;
      % ADDED by Emt
      mStatesMap(sum(mStates(1:m-1))+(1:mStates(m))) = states(multInd(m));
    end
    Rm     = Rm(:,mMap); %Reset all k entries in the 1-of-k encoding of each multinomial variable to nan
    Xm(Rm) = nan;
  end

  params.mMap = mMap;
  params.mStates = mStates;
  params.Mb = Mb;
  params.Mm = length(mMap);
  params.Mc = Mc;
  params.N  = N;
  % ADDED by Emt
  params.mStatesMap = mStatesMap;
