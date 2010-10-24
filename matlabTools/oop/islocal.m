function local = islocal(varargin)
% Return true iff the method is locally defined in the class
% which means
%
% (1) the method is implemented in the class, (or at least abstractly defined so long as allowAbstract = true)
% (2) the method is not the class constructor
% (3) the method is public
% (4) the method is not hidden
%
% Note, the class might be overridding the method of a super class. To
% check that this is not the case, check
% m = methodInfo(className,methodName)
% m.isNewToBranch
%
%
%
% Inputs:
%
% '-methodName'          vectorized w.r.t methodname, (i.e. methodname can be a cell array of strings)
% '-className'
% '-allowAbstract'
%
%
%
% See also, localMethods
% PMTKneedsMatlab 2008

% This file is from pmtk3.googlecode.com


[methodName,className,allowAbstract] = process_options(varargin,'methodName','','className','','allowAbstract',false);
if iscell(methodName)
    local = cellfun(@(mn)islocal(mn,className,allowAbstract),methodName);
    return;
end
minfo = methodInfo(className,methodName);
if isempty(minfo)
    local = false;
else
    local = minfo.isPublic && minfo.isLocal && ~minfo.isHidden && ~minfo.isConstructor && (~minfo.isAbstract || allowAbstract);
end

end
