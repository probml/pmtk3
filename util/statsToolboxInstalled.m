function p = statsToolboxInstalled()
% Determines if user has http://www.mathworks.com/access/helpdesk/help/toolbox/statistics

p = onMatlabPath(fullfile(matlabroot, 'toolbox', 'stats'));
%p = exist('aoctool')>0; % name of obscure toolbox functin
