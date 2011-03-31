function Rnew = efa_flip_obs(R)
  f = fields(R);
  for i=1:length(f)
    if(~isempty(R.(f{i})))
      Rnew.(f{i}) = ~R.(f{i});
    end
  end
end