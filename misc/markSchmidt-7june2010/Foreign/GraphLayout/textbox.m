function [t, wd] = textbox(x,y,str)
% TEXTBOX	Draws A Box around the text 
% 
%  [T, WIDTH] = TEXTBOX(X, Y, STR)
%  [..] = TEXTBOX(STR)
% 
% Inputs :
%    X, Y : Coordinates
%    TXT  : Strings
% 
% Outputs :
%    T : Object Handles
%    WIDTH : x and y Width of boxes 
%% 
% Usage Example : t = textbox({'Ali','Veli','49','50'});
% 
% 
% Note     :
% See also TEXTOVAL

% Uses :

% Change History :
% Date		Time		Prog	Note
% 09-Jun-1998	11:43 AM	ATC	Created under MATLAB 5.1.0.421

% ATC = Ali Taylan Cemgil,
% SNN - University of Nijmegen, Department of Medical Physics and Biophysics
% e-mail : cemgil@mbfys.kun.nl 

% See
temp = [];

switch nargin,
  case 1,
    str = x;
    if ~isa(str,'cell') str=cellstr(str); end;
    N = length(str);  
    wd = zeros(N,2);
    for i=1:N,
      [x, y] = ginput(1);
      tx = text(x,y,str{i},'HorizontalAlignment','center','VerticalAlign','middle');
      [ptc wx wy] = draw_box(tx, x, y); 
      wd(i,:) = [wx wy];
      delete(tx);
      tx = text(x,y,str{i},'HorizontalAlignment','center','VerticalAlign','middle');      
      temp = [temp; tx ptc];
    end;
  case 3,
    if ~isa(str,'cell') str=cellstr(str); end;    
    N = length(str);
    for i=1:N,
      tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle');
      [ptc wx wy] = draw_box(tx, x(i), y(i));
      wd(i,:) = [wx wy];
      delete(tx);
      tx = text(x(i),y(i),str{i},'HorizontalAlignment','center','VerticalAlign','middle');      
      temp = [temp; tx ptc];
    end;
     
  otherwise,

end;  

if nargout>0, t = temp; end;


function [ptc, wx, wy] = draw_box(tx, x, y)
% Draws a box around a tex object
      sz = get(tx,'Extent');
      wy = 2/3*sz(4);
      wx = max(2/3*sz(3), wy);
      ptc = patch([x-wx x+wx x+wx x-wx], [y+wy y+wy y-wy y-wy],'w');
      set(ptc, 'FaceColor','w');

