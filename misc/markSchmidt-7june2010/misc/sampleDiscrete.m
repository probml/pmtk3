function [y] = sampleDiscrete(p)
% Returns a sample from a discrete probability mass function indexed by p
U = rand;
u = 0;
for i = 1:length(p)
   u = u + p(i);
   if u > U
      y = i;
      return;
   end
end
y = length(p);