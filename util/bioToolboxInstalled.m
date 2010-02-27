function p = bioToolboxInstalled()
% Determines if user has http://www.mathworks.com/access/helpdesk/help/toolbox/bioinfo/

p = onMatlabPath(fullfile(matlabroot, 'toolbox', 'bioinfo', 'bioinfo'));
%p = exist('jcampread','file'); % name of obscure toolbox function
