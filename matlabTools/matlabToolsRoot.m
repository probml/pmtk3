function r = matlabToolsRoot()
%% Return the root matlabTools directory

% This file is from matlabtools.googlecode.com

w = which(mfilename());
if w(1) == '.'
    w = fullfile(pwd, w(3:end));
end
r = fileparts(w);
end
