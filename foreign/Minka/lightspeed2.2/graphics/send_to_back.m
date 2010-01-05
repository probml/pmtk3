function send_to_back(handles)
% send_to_back(handles) puts the given objects underneath the other objects in the figure.

children = get(gca,'children');
children = [setdiff(children,handles); handles];
set(gca,'children',children);
