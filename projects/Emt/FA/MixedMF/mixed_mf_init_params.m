function W = mixed_mf_init_parms(Xb,Xm,Xc,params)

 [Nb,Mb]  = size(Xb);
 [Nm,Mm]  = size(Xm);
 [Nc,Mc]  = size(Xc);
 N        = max([Nb Nm Nc]); 

  if Mm>0
    mStates = params.mStates;
    mMap    = params.mMap;
  end
  K = params.K;

  Vb = [];
  Vm = [];
  Vc = [];
  sigma = [];
  
  %Initialize data case factors
  %Firts column will be set to all 1's
  Z  = randn(N,K)/100;
 
  %Initialize binary factors
  if(Mb>0)
    pb = (sum(Xb==1,1)+1)/(N+2);
    Vb = randn(K,Mb)/100;
    %Vb(1,:) = log(pb./(1-pb));
  end

  %Initialize multinomial factors
  if(Mm>0)
    Vm = randn(K,Mm)/100;
    for m = 1:length(mStates);
      pm = (sum(Xm(:,sum(mStates(1:m-1))+(1:mStates(m))),1)+1)/(N+mStates(m));
      %Vm(1,sum(mStates(1:m-1))+(1:mStates(m))) = log(pm);
    end
  end

  %Initialize continuous factors and variances
  if(Mc>0)
  %{
    % added by emt
    Y = Xc'; 
    miss = isnan(Y);
    Y(miss) = 0;
    mean_ = sum(Y,2)./sum(~miss,2);
    Y = bsxfun(@minus, Y,  mean_);
    Y(miss) = 0;
    std_ = sum(Y.^2,2)./sum(~miss,2);
    Y = bsxfun(@rdivide, Y, std_);
    % compute SVD
    covMat = Y*Y';
    [U,S,V] = svd(covMat);
    sigma = sum(sum((covMat - U(:,1:K)*S(1:K,1:K)*V(:,1:K)').^2))/(Mc^2);
    Vc = U(:,1:K)*sqrt(S(1:K,1:K));
    Vc = Vc';
    %}

    sigma = std(Xc(~isnan(Xc)))*ones(Mc,1);
    Vc = randn(K,Mc)/100;
    %Vc(1,:) = mean(Xc(~isnan(Xc)),1); % modified by emt
    %Vc(1,:) = mean(Xc,1);
  end

  W   = pack_mixed_mf_params(Z,Vb,Vm,Vc,sigma);
