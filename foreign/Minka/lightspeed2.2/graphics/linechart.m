function linechart(y,color,varargin)
% LINECHART(Y,COLOR,VARARGIN) provides extra arguments to LABELED_CURVES.
% Examples:
%   linechart(y,color)
% See also LABELED_CURVES.

% sort
f = fieldnames(y);
f = f{1};
v = getfield(y,char(f));
[dummy,order] = sort(v);
for f = fieldnames(y)'
  v = getfield(y,char(f));
  y = setfield(y,char(f),v(order));
end
x = 1:length(v);
x = x(order);
%fprintf('columns are');fprintf(' %d',x);fprintf('\n');

labeled_curves(1:length(x),y,color,varargin{:});
set(gca,'XTick',1:length(x),'XTickLabel',num2str(x'));
axis_pct;
