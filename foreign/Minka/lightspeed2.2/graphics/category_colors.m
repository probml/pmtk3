function colors = category_colors(n)
% category_colors    A good colormap for distinct categories.
% category_colors(n) returns an RGB matrix of n colors.
%
% See also YlGnBu_colors.

% Written by Tom Minka


colors = [0 0 0;255 0 0;0 205 0;0 0 255;0 255 255;255 0 255;255 128 0;128 128 0;0 128 128;128 0 128;255 179 179;179 255 179;179 179 255]/255;
colors = [0 0 0;255 0 0;0 205 0;0 0 255;0 255 255;255 0 255;255 128 0;128 128 0;0 128 128;128 0 128]/255;
i = rem((1:n)-1,rows(colors))+1;
colors = colors(i,:);

