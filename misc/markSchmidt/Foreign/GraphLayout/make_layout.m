function [x, y] = make_layout(adj)
% MAKE_LAYOUT		Creates a layout from an adjacency matrix
%
%  [X, Y] = MAKE_LAYOUT(ADJ)
%
% Inputs :
%	ADJ = adjacency matrix (source, sink)
%
% Outputs :
%	X, Y : Positions of nodes
%
% Usage Example : [X, Y] = make_layout(adj);
%
%
% Note	: Uses some very simple heuristics, so any other
%         algorithm would create a nicer layout 
%
% See also 

% Uses :

% Change History :
% Date		Time		Prog	Note
% 13-Apr-2000	 8:25 PM	ATC	Created under MATLAB 5.3.1.29215a (R11.1)

% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl 

N = size(adj,1);
tps = toposort(adj);

if ~isempty(tps), % is directed ?
  level = zeros(1,N);
  for i=tps,
    idx = find(adj(:,i));
    if ~isempty(idx),
      l = max(level(idx));
      level(i)=l+1;
    end;
  end;
else
  level = poset(adj,1)'-1;  
end;

y = (level+1)./(max(level)+2);
y = 1-y;
x = zeros(size(y));
for i=0:max(level),
  idx = find(level==i);
  offset = (rem(i,2)-0.5)/10;
  x(idx) = (1:length(idx))./(length(idx)+1)+offset;
end;