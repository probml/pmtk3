function h = mobile_points(n, linespec)
% Places n random points in the style given by linespec (e.g. 'bo').
% Points can be dragged with the mouse.

if nargin < 2
  linespec = 'o';
end
ax = axis;
% random placement
x = rand(1,n)*(ax(2)-ax(1)) + ax(1);
y = rand(1,n)*(ax(4)-ax(3)) + ax(3);
h = [];
for i = 1:n
  h = [h line(x(i), y(i), 'linestyle', 'none')];
end
set_linespec(h,linespec);
set(h, 'ButtonDownFcn', 'move_obj(1)');
if nargout < 1
  clear h;
end
