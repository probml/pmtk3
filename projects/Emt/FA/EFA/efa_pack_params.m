function W = efa_pack_params(model,params,type);

  %List of distributions
  dists = sort(fields(params.D));
  N     = params.N;
  K     = params.K;
  W     = [];

  %Extract latent factors if needed
  if(strcmp(type,'all') | strcmp(type,'Z'))
    %Extract data factors
    tmp       = model.Z(:,2:end); 
    W         = [W;tmp(:)];    
  end
  
  %Extract parameters for each distribution
  if(strcmp(type,'all') | strcmp(type,'noZ'))
    %Loop over distributions 
    for d=1:length(dists)
     %Loop over parameters in each distribution
     parameters = sort(fields(params.D.(dists{d})));
     for p=1:length(parameters)
      %Get size of each paramater
      W = [W;model.(dists{d}).(parameters{p})(:)];
     end
    end  
  end
end

  
