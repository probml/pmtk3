function set_linespec(h,linespec)
% SET_LINESPEC    Set the color and line style of a graphics object.
% SET_LINESPEC(h,linespec) will set the color and line style of a graphics
% object, using the linespec convention of 'plot', e.g. 
%   set_linespec(h,'g:')
%   set_linespec(h,'r--')

% break linespec into color and linestyle.
[linestyle, color, marker, msg] = colstyle(linespec);
if ~isempty(msg)
  error(msg)
end
if length(color) > 0
  if strcmp(get(h,'Type'),'patch')
    set(h,'EdgeColor',color);
  else
    set(h,'color',color);
  end
end
if length(linestyle) > 0
  set(h,'linestyle',linestyle);
end
if length(marker) > 0
  set(h,'marker',marker);
end
