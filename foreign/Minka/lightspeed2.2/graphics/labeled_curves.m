function h = labeled_curves(x,y,varargin)
%LABELED_CURVES   Draw multiple curves in different colors with labels.
% LABELED_CURVES(X,Y) plots multiples curves in different colors, with
% a legend and good axes (using AXIS_PCT).
% There are multiple ways to specify X and Y.
%
% In the simplest case, every curve has the same x-coordinates, so X is
% just a vector and Y is a matrix.  Y can also be a structure where each
% field is a vector of y-coordinates (of equal lengths).
%
% If curves have different x-coordinates then X should be a structure where 
% each field is a vector of x-coordinates, and Y is a corresponding structure 
% where each field is a vector of y-coordinates.
%
% LABELED_CURVES(X,Y,'color',COLOR) uses the given colors.
% COLOR is either a cell array of linespec strings (as in PLOT),
% a matrix of RGB triples (as in COLORMAP), or a structure where each field
% is either a linespec string or RGB triple. 
%
% If you are making multiple plots, you can collect all the color 
% specifications into a single color structure, which ensures the coloring 
% of a particular curve is consistent among plots.
%
% By default, the structure field names are used as labels.  Alternatively,
% you can specify labels as an optional argument:
%
% LABELED_CURVES(X,Y,...,'labels',LABELS) uses the given labels for the legend 
% (LABELS is a cell array of strings). Otherwise the field names are used.  
%
% LABELED_CURVES(X,Y,...,'plotfun',PLOTFUN) uses PLOTFUN instead of 'plot' to 
% draw the curves.  For example, 'semilogx', 'semilogy', or 'loglog'.
%
% LABELED_CURVES(X,Y,...,'mobile',1) uses MOBILE_TEXT instead of 
% LEGEND, for more accurate placement of labels.
%
% Example:
%   x = linspace(0,6,100);
%   y = [sin(x); cos(x)];
%   labeled_curves(x,y,'labels',{'sin' 'cos'})
%   color = {'g' 'b'};
%   labeled_curves(x,y,'color',color,'labels',{'sin' 'cos'})
%   color = [0 1 0; 0 0 1];
%   labeled_curves(x,y,'color',color,'labels',{'sin' 'cos'})
%
%   y=struct;color=struct;
%   y.sin = sin(x);
%   y.cos = cos(x);
%   color.sin = 'g';
%   color.cos = 'b';
%   labeled_curves(x,y,'color',color)
%   labeled_curves(x,y,'color',color,'plotfun','semilogx','mobile',1)
%
%   xcoord = struct;
%   xcoord.sin = x;
%   xcoord.cos = x;
%   xcoord.tan = linspace(2,4,100);
%   y.tan = tan(xcoord.tan);
%   color.tan = [1 0 0];
%   labeled_curves(xcoord,y,'color',color)
%
% See also PLOT, LEGEND, MOBILE_TEXT, AXIS_PCT, LINECHART

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

args = makestruct(varargin);
default_args = struct('color',[],'labels',[],'plotfun','plot','mobile',0,'dotstyle','.');
args = setfields(default_args,args);
color = args.color;
labels = args.labels;
plotfun = args.plotfun;
mobile_flag = args.mobile;
dotstyle = args.dotstyle;

if ~isstruct(y)
  a = y;
  y = struct;
  for i = 1:rows(a)
    y.(sprintf('V%d',i)) = a(i,:);
  end
end
if isempty(color)
  n = length(fieldnames(y));
  color = jet(n);
  color = hsv(n);
end
if ~isstruct(color)
  a = color;
  color = struct;
  fields = fieldnames(y);
  if iscellstr(a)
    for i = 1:length(a)
      color.(fields{i}) = a{i};
    end
  else
    for i = 1:rows(a)
      color.(fields{i}) = a(i,:);
    end
  end
end
if isempty(labels)
  labels = fieldnames(y);
end

lastx = struct;
lasty = struct;
h = [];
for f = fieldnames(y)'
  field = char(f);
  if isstruct(x)
    thisx = x.(field);
  else
    thisx = x;
  end
  thisy = y.(field);
  thiscolor = color.(field);
  if ischar(thiscolor)
    h(end+1) = feval(plotfun,thisx,thisy,thiscolor);
    hold on
    if ~isempty(dotstyle)
      feval(plotfun,thisx,thisy,[thiscolor dotstyle]);
    end
  else
    h(end+1) = feval(plotfun,thisx,thisy);
    set(h(end),'Color',thiscolor);
    hold on
    if ~isempty(dotstyle)
      hh = feval(plotfun,thisx,thisy,dotstyle);
      set(hh,'Color',thiscolor);
    end
  end
  lastx.(field) = thisx(end);
  lasty.(field) = thisy(end);
end
hold off
axis_pct;
f = fieldnames(y);
legend(h,labels)
if mobile_flag
  legend off
  hlab = mobile_text(labels{:});
  for i = 1:length(hlab)
    set(hlab(i),'Position',[lastx.(f{i}) lasty.(f{i})]);
  end
end
if nargout == 0
  clear h
end
