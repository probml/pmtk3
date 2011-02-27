%% Figure out rank of linear dependencies in misconception Markov network
% Koller and Friedman ex 4.4.14
%%

% This file is from pmtk3.googlecode.com

edges = {[1 2], [1 3], [2 4], [3 4]};
ndx  = 1;
F = zeros(0, 2^4);
for e=1:length(edges)
  s = edges{e}(1); t = edges{e}(2);
  for j=1:2
    for k=1:2
      if j==2 && k==2, continue; end 
      for x=1:16
        xv= ind2subv([2 2 2 2], x);
        if xv(s)==j && xv(t)==k
          F(ndx,x)=1;
        end
      end
      ndx = ndx + 1;
    end
  end
end
rank(F)
