function [x, y, h] = draw_layout(adj, labels, node_t, x, y)
% DRAW_LAYOUT		Draws a layout for a graph 
%
%  [<X, Y>] = DRAW_LAYOUT(ADJ, <LABELS, ISBOX, X, Y>)
%
% Inputs :
%	ADJ : Adjacency matrix (source, sink)
%       LABELS : Cell array containing labels <Default : '1':'N'>
%       ISBOX : 1 if node is a box, 0 if oval <Default : zeros>
%       X, Y, : Coordinates of nodes on the unit square <Default : calls make_layout>
%
% Outputs :
%	X, Y : Coordinates of nodes on the unit square
%       H    : Object handles 
%
% Usage Example : [x, y] = draw_layout([0 1;0 0], {'Hidden','Visible'}, [1 0]');
%
%
% Note	:
% See also MAKE_LAYOUT

% Uses :

% Change History :
% Date		Time		Prog	Note
% 13-Apr-2000	 9:06 PM	ATC	Created under MATLAB 5.3.1.29215a (R11.1)

% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl 
clf
N = size(adj,1);
if nargin<2,
%  labels = cellstr(char(zeros(N,1)+double('+')));
  labels = cellstr(int2str((1:N)'));
end;

if nargin<3,
  node_t = zeros(N,1);
%  node_t = rand(N,1) > 0.5;
else
  node_t = node_t(:);
end;
  
axis([0 1 0 1]);
set(gca,'XTick',[],'YTick',[],'box','on');
% axis('square');
%colormap(flipud(gray));

if nargin<4,
  [x y] = make_layout(adj);
end;

idx1 = find(node_t==0); wd1=[];
if ~isempty(idx1),
[h1 wd1] = textoval(x(idx1), y(idx1), labels(idx1));
end;

idx2 = find(node_t~=0); wd2 = [];
if ~isempty(idx2),
[h2 wd2] = textbox(x(idx2), y(idx2), labels(idx2));
end;

wd = zeros(size(wd1,1)+size(wd2,1),2);
if ~isempty(idx1), wd(idx1, :) = wd1;  end;
if ~isempty(idx2), wd(idx2, :) = wd2; end;

for i=1:N,
  j = find(adj(i,:)==1);
  for k=j,
    if x(k)-x(i)==0,
	sign = 1;
	if y(i)>y(k), alpha = -pi/2; else alpha = pi/2; end;
    else
	alpha = atan((y(k)-y(i))/(x(k)-x(i)));
	if x(i)<x(k), sign = 1; else sign = -1; end;
    end;
    dy1 = sign.*wd(i,2).*sin(alpha);   dx1 = sign.*wd(i,1).*cos(alpha);
    dy2 = sign.*wd(k,2).*sin(alpha);   dx2 = sign.*wd(k,1).*cos(alpha);    
    if adj(k,i)==0, % if directed edge
      arrow([x(i)+dx1 y(i)+dy1],[x(k)-dx2 y(k)-dy2]);
    else	   
      line([x(i)+dx1 x(k)-dx2],[y(i)+dy1 y(k)-dy2],'color','k');
      adj(k,i)=-1; % Prevent drawing lines twice
    end;
  end;
end;

if nargout>2,
  h = zeros(length(wd),2);
  if ~isempty(idx1),
    h(idx1,:) = h1;
  end;
  if ~isempty(idx2),
    h(idx2,:) = h2;
  end;
end;