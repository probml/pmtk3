function f = whoDependsOnToolbox(TB, recache)
% Return a list of all user files on the path that recursively depend on a toolbox
%% Input
% TB      - the name of a toolbox, e.g. 'stats', 'images', 'optim'
%
% recache - [false] if true, the whoCallsMe cache is updated
%% Output
% f      - a list of user mfiles that depend directly or indirectly, on the
%          toolbox.
%
%% Examples
%
% f = whoDependsOnToolbox('stats');
% f = whoDependsOnToolbox('optim');
% f = whoDependsOnToolbox('images');
% f = whoDependsOnToolbox('bioinfo');
%% See also
% deptoolbox - returns more info but is not recursive
%%

% This file is from pmtk3.googlecode.com

if nargin < 2, recache = false; end
tbdir = fullfile(matlabroot(), 'toolbox', TB);
if ~exist(tbdir, 'file')
    error('could not find %s toolbox', TB);
end
[l, m, G] = whoCallsMe('whoCallsMe', 'recursive', false, 'recache', recache);
usesTB    = @(f)any(strncmp(tbdir, depfun(f, '-toponly', '-quiet'), length(tbdir)));
try
    tbdep = cellfun(usesTB, m);
catch ME 
    fprintf('There was an error generating the report - try recaching...\n');
    f = {};
    return
end
G         = [[G, tbdep(:)]; zeros(1, length(G)+1)]; % call graph
R         = expm(sparse(G)); % reachability graph
f         = m(R(1:end-1, end) > 0);
end
