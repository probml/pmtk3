function color_plot(x,colors,varargin)
% COLOR_PLOT    Scatterplot with colored points.
% color_plot(x) makes a scatterplot of x(:,1) versus x(:,2) with points colored
% according to quantiles of x(:,3).
% color_plot(x,n) specifies the number of color quantiles (default 4).
% color_plot(x,colors) specifies an RGB matrix of colors (the number of rows
% determines the number of quantiles).  The default is YlGnBu_colors.
% color_plot(...,'ColorBar',1) adds a color bar with tick marks from the
% quantile values.
%
% Example:
%   xy = ndgridmat(linspace(-12,12,20),linspace(-12,12,20));
%   z = sin(sqrt(xy(:,1).^2 + xy(:,2).^2));
%   color_plot([xy z]);
%
% See also YlGnBu_colors.

% Written by Tom Minka and Charles Sutton

args = makestruct(varargin);
default_args = struct('ColorBar',0);
args = setfields(default_args,args);

if nargin < 2
  colors = 4;
end
if length(colors) == 1
  nlevels = colors;
  colors = YlGnBu_colors(nlevels);
else
  nlevels = rows(colors);
end
% color groups
[c,q] = cut_quantile(x(:,3),nlevels);
for lev = 1:nlevels
  i = find(c == lev);
  plot(x(i,1),x(i,2),'o','Color',colors(lev,:),'MarkerFaceColor',colors(lev,:));
  hold on
end
hold off

colormap(colors);

if args.ColorBar 
  caxis ([0,1]);
  
  cTickLbls = cell(numel(q), 1);
  for i = 1:length(q)
      cTickLbls{i} = num2str(q(i), '%11.2g');
  end
  
  colorbar('YTick', linspace(0,1,nlevels+1), 'YTickLabel', cTickLbls);
end

set(gca,'Color','none')
