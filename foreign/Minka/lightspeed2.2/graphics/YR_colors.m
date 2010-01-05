function colors = YR_colors(n)
% YR_colors    A good sequential colormap.
% YR_colors(n) returns an RGB matrix of n colors (default 64).
% These colors form a sequential colormap (colors easily perceived to lie
% on a sequence).
%
% Example:
%   colormap(YR_colors)
%
% See also YlGnBu_colors

% Written by Tom Minka

if nargin < 1
  n = 64;
end

lt = 0.97;
dk = 0.03;
k = ceil(n/3);
lts = repmat(lt,1,k);
dks = repmat(dk,1,k);
span = linspace(lt,dk,k+1);
span = span(1:(end-1));
r = [lts lts span];
g = [lts span dks];
b = [span dks dks];
colors = [r;g;b]';
colors = flipud(colors);
i = round(linspace(1,rows(colors),n));
colors = colors(i,:);
