function [Xbhat,Xmhat,Xchat,Z] = befa_predict(Xb,Xm,Xc,models,sampleZ)

[Nb,Db]           = size(Xb);
[Nm,Dm]           = size(Xm);
[Nc,Dc]           = size(Xc);
N                 = max([Nb Nm Nc]);

Xbhat = zeros(size(Xb));
Xmhat = zeros(size(Xm));
Xchat = zeros(size(Xc));
Z     = 0;
M     = length(models);

%Compute predictions under each saved model
for m=1:length(models)
  
  if(sampleZ)
    %Zinit = mixed_mf_infer(Xb,Xm,Xc,models(m));
    %Zinit = Zinit(:,2:end);
    Zinit = rand(N,models(m).K-1)/100;
    infer = befa_inference_hmc(Xb, Xm, Xc, Zinit(:), models(m), []);
 
    I = length(infer);
    for i=1:I
      models(m).Z = infer(i).Z;
      [Xbhatnew,Xmhatnew,Xchatnew,Znew] = mixed_mf_predict(Xb,Xm,Xc,models(m));
      if(~isempty(Xb))
	Xbhat = Xbhat + Xbhatnew/(I*M);
      end
      if(~isempty(Xm))
	Xmhat = Xmhat + Xmhatnew/(I*M);
      end
      if(~isempty(Xc))
	Xchat = Xchat + Xchatnew/(I*M);
      end
      Z = Z + Znew/M;
    end
  else
    [Xbhatnew,Xmhatnew,Xchatnew,Znew] = mixed_mf_predict(Xb,Xm,Xc,models(m));
    if(~isempty(Xb))
      Xbhat = Xbhat + Xbhatnew/M;
    end
    if(~isempty(Xm))
      Xmhat = Xmhat + Xmhatnew/M;
    end
    if(~isempty(Xc))
      Xchat = Xchat + Xchatnew/M;
    end
    Z = Z + Znew/M;
  end



end