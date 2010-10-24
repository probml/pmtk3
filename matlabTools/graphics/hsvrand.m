function colors = hsvrand(N)
% hsvrand Like built-in HSV, except it randomizes the order, so that adjacent colors are dis-similar
% function colors = hsvrand(N)

% This file is from pmtk3.googlecode.com


colors = hsv(N);
perm = randperm(N);
colors = colors(perm,:);


end
