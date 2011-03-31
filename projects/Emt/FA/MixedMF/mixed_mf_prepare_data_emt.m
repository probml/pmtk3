function [Xb,Xm,Xc,params] = mixed_mf_prepare_data_emt(data, nClass);
% difference from mixed_mf_prepare_Data(): added nClass as input

  [Md,Nd] = size(data.discrete);
  [Mc,Nc] = size(data.continuous);

  N = max(Nd,Nc);
  params.N  = N;

  % continuous data
  if Mc>0
    Xc = data.continuous';
  else
    Xc = [];
  end
  params.Mc = Mc;

  % discrete data
  if(Md>0)
    states  = nClass; % modified by emt
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

    % added by emt
    dataNew = encodeDataOneOfM(data.discrete(multInd,:), nClass(multInd), 'M');
    Xm = dataNew';
    for m = 1:Mm
      %Xm(:,sum(mStates(1:m-1))+(1:mStates(m))) = full(sparse(1:N,data.discrete(multInd(m),:),ones(N,1)));
      mMap(sum(mStates(1:m-1))+(1:mStates(m))) = m;
    end
    Rm     = Rm(:,mMap); %Reset all k entries in the 1-of-k encoding of each multinomial variable to nan
    Xm(Rm) = nan;
    params.mMap = mMap;
    params.mStates = mStates;
    params.Mm = length(mMap);
    params.Mb = Mb;
  else
    Xm = [];
    Xb = [];
    params.mMap = [];
    params.mStates = [];
    params.Mm = 0;
    params.Mb = 0;
  end
