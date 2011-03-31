function [Xhat,Z] = efa_predict(X,R,models,options)

[method,use_old_Z] = myProcessOptions(options,'method','M','use_old_Z',0);

dists = sort(fields(X));
N = efa_get_N(X);
Z = 0;
M = length(models);

%Initialize prediction for each distribution
for d=1:length(dists)
  Xhat.(dists{d}) = zeros(size(X.(dists{d})));
end  

%Compute predictions under each saved model
for m=1:M
  %fprintf('%d\n',m);
  %Infer latent factors or use stored factors
  if(~use_old_Z)
    infer = efa_infer(X, R,[], models(m),options);
  else
    infer.Z = models(m).Z;
  end

  %For each set of inferred latent states,
  %compute and average predictions
  I = length(infer);
  for i=1:I
    Z = infer(i).Z;

    %Loop over each distribution and make predictions
    for d=1:length(dists)
      predict = str2func(sprintf('efa_predict_%s',dists{d}));
      Xhat.(dists{d}) = Xhat.(dists{d}) + predict(Z,models(m).(dists{d}),models(m).params)/(M*I);
    end  
    
  end

end

