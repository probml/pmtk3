function softev = obsModelEval(model, features)
% Use observatino model to convert local features to soft evidence 
% features(n,t,d) is obs for node t, case n, component d
% softev(k,t,n) is p(node(t)=k | case n) 
%
% This is a batch version of localEvToSoftEv
% that is much faster

% This file is from pmtk3.googlecode.com

[Ncases, Nnodes, Ndims] = size(features);
Nstates = model.Nstates;
softev = zeros(Nstates, Nnodes, Ncases);

switch model.obsType
  case 'localev'
    if Ndims==1 % we assume features=prob(yt=on)
      softev(1,:,:) = 1-features';
      softev(2,:,:) = features';
    else
      softev = permute(features, [3 1 2]);
    end
    
  case 'gauss'
    for t=1:Nnodes
      for k=1:Nstates
        mu = model.mu(:,k,t);
        Sigma = model.Sigma(:,:,k,t);
        X = permute(features(:, t, :), [1 3 2]); % n d  - cases are rows
        softev(k,t,:)  = reshape(gaussLogprob(mu, Sigma, X), [1 1 Ncases]);
      end
      %softev(:,t,:) = exp(normalizeLogspace(softev(:,t,:)));
      softev(:,t,:) = exp(softev(:,t,:));
    end

  case 'quantize'
    %YQ = quantizePMTK(features, 'levels', model.Nbins);
    YQ = discretizePMTK(features, [], model.discretizeParams);
    for t=1:Nnodes
      % model.CPT(x,y,t)
      B = model.CPT(:, YQ(:,t), t);
      softev(:,t,:) = reshape(B, [Nstates 1 Ncases]);
    end
end

end


