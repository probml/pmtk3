function [model] = efa_unpack_params(W,params,type);

  %List of distributions
  dists = sort(fields(params.D));
  N     = params.N;
  K     = params.K;

  %Extract latent factors if needed
  if(strcmp(type,'all') | strcmp(type,'Z'))
    %Extract data factors  
    tmp       = W(1:N*(K-1));
    model.Z   = [ones(N,1),reshape(tmp,[N,K-1])];
    W         = W(N*(K-1)+1:end);
  end
  
  %Extract parameters for each distribution
  if(strcmp(type,'all') | strcmp(type,'noZ'))
    %Loop over distributions 
    for d=1:length(dists)
     %Loop over parameters in each distribution
     parameters = sort(fields(params.D.(dists{d})));
     for p=1:length(parameters)
      %Get size of each paramater
      psize = params.D.(dists{d}).(parameters{p});
      %Parameters that depend on the latent dimension size
      %use nan as a place holder. Replace the nan's with K.
      psize(isnan(psize)) = K;
      %Extract data for parameter and reshape
      tmp = W(1:prod(psize));
      model.(dists{d}).(parameters{p}) = reshape(tmp,psize);
      W  = W((prod(psize)+1):end);
     end
    end  
  end
end
   
  
