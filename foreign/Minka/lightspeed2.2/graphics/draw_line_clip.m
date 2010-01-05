function h = draw_line_clip(m,b,a, linespec, varargin)
%DRAW_LINE_CLIP  Draw a line defined by an equation.
% DRAW_LINE_CLIP(M,B,A) draws a line, clipped to the current axes, 
% defined by a*y = m*x + b.
% DRAW_LINE_CLIP(M,B,A,LINESPEC) also specifies the line style and color.

if nargin < 4
  linespec = 'b';
end
v = axis;
x1 = v(1);
x2 = v(2);
warning off
y1 = (m*x1 + b)/a;
y2 = (m*x2 + b)/a;
warning on
if y1 < v(3)
  y1 = v(3);
  x1 = (a*y1 - b)/m;
end  
if y1 > v(4)
  y1 = v(4);
  x1 = (a*y1 - b)/m;
end  
if y2 < v(3);
  y2 = v(3);
  x2 = (a*y2 - b)/m;
end
if y2 > v(4);
  y2 = v(4);
  x2 = (a*y2 - b)/m;
end
h = line([x1 x2], [y1 y2]);
set_linespec(h,linespec);
if length(varargin) > 0
  set(h,varargin{:});
end
if nargout < 1
  clear h
end
