function colors = hsvrand(N)
% hsvrand Like built-in HSV, except it randomizes the order, so that adjacent colors are dis-similar
% function colors = hsvrand(N)

colors = hsv(N);
perm = randperm(N);
colors = colors(perm,:);
