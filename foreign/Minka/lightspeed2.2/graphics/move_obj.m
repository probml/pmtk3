function move_obj(arg)
% callback function for draggable objects
% Any object can be made draggable via
%   set(obj, 'ButtonDownFcn', 'move_obj(1)');

% using deltas allows us to drag big objects
persistent last_pos;
persistent windowbuttonmotionfcn;
persistent windowbuttonupfcn;

% handle events
switch arg
  case 2    % button motion
    pos = get(gca, 'CurrentPoint');
    pos = pos(1,:);

    switch get(gco, 'type')
      case 'text', obj_pos = get(gco, 'Pos')';
      case 'line', 
	obj_pos(1,:) = get(gco,'xdata');
	obj_pos(2,:) = get(gco,'ydata');
      otherwise error(['cannot handle type ' get(gco,'type')])
    end
    % if the scale is logarithmic then the delta is a ratio
    if strcmp(get(gca,'xscale'), 'log')
      new_pos(1,:) = obj_pos(1,:) * (pos(1)/last_pos(1));
    else
      new_pos(1,:) = obj_pos(1,:) + (pos(1)-last_pos(1));
    end
    if strcmp(get(gca,'yscale'), 'log')
      new_pos(2,:) = obj_pos(2,:) * (pos(2)/last_pos(2));
    else
      new_pos(2,:) = obj_pos(2,:) + (pos(2)-last_pos(2));
    end
    switch get(gco, 'type')
      case 'text', set(gco, 'Pos', new_pos);
      case 'line',
	set(gco, 'xdata', new_pos(1,:), ...
	         'ydata', new_pos(2,:));
    end
    last_pos = pos;
  case 1    % buttondown
    % start moving
    % dragging looks better with double buffering on
    set(gcf, 'DoubleBuffer', 'on');
    last_pos = get(gca,'CurrentPoint');
    last_pos = last_pos(1,:);
    % set callbacks
    fig = gcf;
    %set(fig, 'pointer', 'fleur');
    windowbuttonmotionfcn = get(fig,'windowbuttonmotionfcn');
    windowbuttonupfcn = get(fig,'windowbuttonupfcn');
    set(fig, 'windowbuttonmotionfcn', ['move_obj(2);' windowbuttonmotionfcn]);
    set(fig, 'windowbuttonupfcn', ['move_obj(3);' windowbuttonupfcn]);
  case 3    % button up
    % finished moving
    % clear callbacks
    fig = gcf;
    %set(fig, 'pointer', 'arrow');
    set(fig, 'windowbuttonmotionfcn', windowbuttonmotionfcn);
    set(fig, 'windowbuttonupfcn', windowbuttonupfcn);
  otherwise
    error('invalid argument')
end
