function normalGammaPenaltyPlotDemo()
% Plot contours of penalty(w1) + penalty(w2)
% where penalty(w) = -log p(w)
% and p(w) = normalGamma(w | delta, c)

%#author Francois Caron

c = 1;
pas=.002;
[X,Y]=meshgrid(-1:pas:1,-1:pas:1.1);
[styles, colors, symbols] =  plotColors; %#ok
deltas = [0.01 0.75 1 2];
figure; hold on
for i=1:length(deltas)
  delta = deltas(i);
  Z=pen_normalgamma(X,delta,c)+pen_normalgamma(Y,delta,c)...
    -pen_normalgamma(1,delta,c)-pen_normalgamma(pas,delta,c);
  contour(X,Y,Z,[0 0], styles{i}, 'linewidth', 2);
  str{i} = sprintf('%s=%3.2f, c=1', '\delta', delta);
end
legend(str)
title(sprintf('penalty induced by normalGamma(%s,c) prior', '\delta'))
printPmtkFigure('normalGammaPenalty')

  
end

function out=pen_normalgamma(w, delta, c)
gamma = sqrt(2*c);
warning off
out=(.5-delta)*log(abs(w))-log(besselk(delta-.5,gamma*abs(w)));
warning on
end