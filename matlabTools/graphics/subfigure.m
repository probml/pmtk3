function varargout = subfigure(varargin)
% h = subfigure(m,n,p), or subfigure(mnp), divides the screen into an m-by-n
% matrix, creates a figure within the pth matrix element, and returns that
% figure's handle. The figures are counted along the top row of the screen, then
% the second row, etc. For example,
%
%     income = [3.2 4.1 5.0 5.6];
%     outgo = [2.5 4.0 3.35 4.9];
%     subfigure(2,1,1)
%     plot(income)
%     subfigure(2,1,2)
%     plot(outgo)
%
% plots income on the top half of the screen and outgo on the bottom half.
%
% subfigure(m,n,p), where p is a vector, specifies a figure position that covers
% all the subfigure positions listed in p. For example,
%
%     subfigure(2,2,[1,3])
%     subfigure(2,2,2)
%     subfigure(2,2,4)
%
% creates a layout with one large plot on the left and two smaller plots on the
% right.
%
% subfigure(m,n,'showgrid') displays an m-by-n grid with matrix elements labeled
% in the order that they are indexed by subfigure. This is useful for planning
% screen layouts, especially when one or more subfigures will span multiple subfigure
% positions (when p is a vector).
%
% Every call to subfigure creates a new figure even if a figure exists at the
% location specified by m, n, and p. The existing figure is not made current.
% Existing figures that are overlapped by a new subfigure are not deleted. This
% behavior is dissimilar to subplot.

% This file is from pmtk3.googlecode.com


%PMTKauthor Steve Hoelzer
%PMTKdate  May 13, 2004

% Process input arguments
if nargin == 1
    m = floor(varargin{1}/100);
    n = rem(floor(varargin{1}/10),10);
    p = rem(varargin{1},10);
elseif nargin == 3
    m = varargin{1};
    n = varargin{2};
    p = varargin{3};
else
    error('Incorrect number of input arguments.')
end

% Show example grid for planning layouts
if strcmp(lower(p),'showgrid')
    p = m*n;
    figure('NumberTitle','Off',...
        'Name','Subfigure example grid for planning plot layouts')
    for i = 1:p
        h = subplot(m,n,i);
        set(h,'Box','On',...
            'XTick',[],...
            'YTick',[],...
            'XTickLabel',[],...
            'YTickLabel',[])
        text(0.5,0.5,int2str(i),...
            'FontSize',16,...
            'HorizontalAlignment','Center')
    end
    return
end

% Error checking
if m*n < p
    error('Index exceeds number of subfigures.')
end

% Calculate tile size and spacing
hpad = 20;
vpad = 90;
scrsz = get(0,'ScreenSize');
hstep = floor( (scrsz(3)-hpad) / n );
vstep = floor( (scrsz(4)-vpad) / m );
vsz = vstep - vpad;
hsz = hstep - hpad;

% Let subfigure span multiple subfigure locations
le = Inf;
ri = 0;
bo = Inf;
to = 0;
for i = 1:length(p)
    r = ceil(p(i)/n);
    c = rem(p(i),n);
    if c == 0
        c = n;
    end
    
    newle = hpad+(c-1)*hstep;
    newri = newle + hsz;
    newbo = vpad+(m-r)*vstep;
    newto = newbo + vsz;
    
    le = min(le,newle); % Leftmost left
    ri = max(ri,newri); % Rightmost right
    bo = min(bo,newbo); % Lowest bottom
    to = max(to,newto); % Highest top
end

% Create subfigure
position = [le, bo, ri-le, to-bo];
h = figure('Position',position);

% Return handle if needed
if nargout
    varargout{1} = h;
end

end
