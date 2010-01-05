function colors = YlGnBu_colors(n)
% YlGnBu_colors    A good sequential colormap.
% YlGnBu_colors(n) returns an RGB matrix of n colors (default 4).
% These colors form a sequential colormap (colors easily perceived to lie
% on a sequence).
%
% Example:
%   colormap(YlGnBu_colors(32))
%
% See also YR_colors

% Written by Tom Minka

if nargin < 1
  n = 4;
end

if n == 4
  colors = [1 1 0.8; 0.63 0.855 0.706; 0.255 0.714 0.765; 0.22 0.42 0.69];
else
  error('can''t make that many levels');
end
