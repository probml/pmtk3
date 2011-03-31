function W = efa_init_params(params,type,varargin);

  %List of distributions
  dists = sort(fields(params.D));
  N     = params.N;
  K     = params.K;
  W     = [];

  if(nargin==2)
    init_func = @rand;
  else
    init_func = varargin{1};
  end

  %Extract latent factors if needed
  if(strcmp(type,'all') | strcmp(type,'Z'))
    %Extract data factors  
    W       = [W,init_func(N*(K-1),1)/100];
  end
  
  %Extract parameters for each distribution
  if(strcmp(type,'all') | strcmp(type,'noZ'))
    %Loop over distributions 
    for d=1:length(dists)
     %Loop over parameters in each distribution
     parameters = sort(fields(params.D.(dists{d})));
     for p=1:length(parameters)
      %Get size of paramater. 
      psize = params.D.(dists{d}).(parameters{p});
      %Parameters that depend on the latent dimension size
      %use nan as a place holder. Replace the nan's with K.
      psize(isnan(psize)) = K;
      %All parameters must be unconstrained. Init from Gaussian.
      W     = [W;init_func(prod(psize),1)/100]; 
     end
    end  
  end

end  
