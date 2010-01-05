function h = mobile_text(varargin)
% MOBILE_TEXT('str1', 'str2', ...) places each string in a random position
% on the current axes.  The strings can be dragged around with the mouse.
% Returns handles to the text objects, for setting colors, etc.

strs = varargin;
n = length(strs);
ax = axis;
% random placement
x = rand(1,n)*(ax(2)-ax(1)) + ax(1);
y = rand(1,n)*(ax(4)-ax(3)) + ax(3);
h = [];
for i = 1:n
  h = [h text(x(i),y(i),strs{i})];
end
set(h,'ButtonDownFcn','move_obj(1)');
if nargout == 0
  clear h
end
