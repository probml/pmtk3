function p = isprefix(short, long)
% Return true iff the first input is a prefix of the second
% The second arg may also be a cell array of strings, in which case, each
% is tested. CASE SENSITIVE!
%
% If the second argument is not a string, p = false, it does not error. 
%
% EXAMPLES:
% 
% isprefix('foo','foobar')
% ans =
%      1
%
%isprefix('test_',{'test_MvnDist','test_DiscreteDist','UnitTest'})
%ans =
%     1     1     0

% This file is from pmtk3.googlecode.com

    error(nargchk(2,2,nargin));
    if ischar(long)
        p = strncmp(long,short,length(short));
    elseif iscell(long)
        p = cellfun(@(c)isprefix(short,c),long);
    else
        p  = false;
    end
end
