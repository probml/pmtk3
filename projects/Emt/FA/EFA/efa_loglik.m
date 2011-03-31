function [f,g] = efa_loglik(W,X,R,models_fixed,params,type)

 N = efa_get_N(X);
 params.N = N;
 dists = sort(fields(X));

 K = params.K;
 f = 0;
 g = efa_init_params(params,type,@zeros);
 g = efa_unpack_params(g,params,type); 
 M = max(1,length(models_fixed));

 for m=1:M

    %Select parts of fixed model and combine with variable parts 
    %of the parameter vector W.
    switch(type)
      case 'all'
	[model] = efa_unpack_params(W,params,'all');
	Z = model.Z;
      case 'noZ'
	[model] = efa_unpack_params(W,params,'noZ');
	Z = models_fixed(m).Z;       
      case 'Z'
	[model] = efa_unpack_params(W,params,'Z');
	Z = model.Z;
	model = models_fixed(m); 
    end

    if(isfield(params,'use_weights') & params.use_weights);
      weight = params.weights(m);
    else
      weight = 1/M;
    end

    %Compute objective and gradient 
    for d=1:length(dists)
      %Loop over parameters in each distribution
      %and calculate likelihood and gradient contributions 
      loglik_func = str2func(sprintf('efa_loglik_%s',dists{d})); 
      if(nargout==1)
	  ftmp = weight*loglik_func(X.(dists{d}),R.(dists{d}),Z,model.(dists{d}),params,type);
	  f = f + ftmp;
      else
	[ftmp,gZtmp,gdtmp] = loglik_func(X.(dists{d}),R.(dists{d}),Z,model.(dists{d}),params,type);
	f = f + weight*ftmp;      
	if(~isempty(gZtmp))
	  g.Z = g.Z + weight*gZtmp;
	end
	if(~isempty(gdtmp))
	  parameters = sort(fields(gdtmp));
	  for p=1:length(parameters)
	    g.(dists{d}).(parameters{p}) = g.(dists{d}).(parameters{p}) + weight*gdtmp.(parameters{p});
          end
        end
      end   
    end

    %compute objective and gradient wrt regularization on Z
    Znew = Z(:,2:end);
    f = f - weight*0.5*params.lambdaZ*Znew(:)'*Znew(:);
    if(nargout>1 & (strcmp(type,'all') | strcmp(type,'Z')))
      g.Z = g.Z - weight*params.lambdaZ*Z;
    end

  end

  %Flip sign on objective and gradient for minimization, and
  %pack gradient into vector if needed 
  f = -f/N;
  if(nargout>1)
    g = efa_pack_params(g,params,type);
    g = -g(:)/N;
  end

  if(isnan(f)); keyboard;end;

return


