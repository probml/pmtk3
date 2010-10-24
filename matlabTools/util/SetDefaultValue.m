function SetDefaultValue(position, argName, defaultValue)
% Initialize a missing or empty value in the caller function
% 
% SETDEFAULTVALUE(POSITION, ARGNAME, DEFAULTVALUE) checks to see if the
% argument named ARGNAME in position POSITION of the caller function is
% missing or empty, and if so, assigns it the value DEFAULTVALUE.
% 
% Example:
% function x = TheCaller(x)
% SetDefaultValue(1, 'x', 10);
% end
% TheCaller()    % 10
% TheCaller([])  % 10
% TheCaller(99)  % 99
% 
% $Author: Richie Cotton $  $Date: 2010/03/23 $
%PMTKauthor Richie Cotton
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/27056-set-default-values
%PMTKdate March 23, 2010

% This file is from pmtk3.googlecode.com

if evalin('caller', 'nargin') < position || ...
      isempty(evalin('caller', argName))
   assignin('caller', argName, defaultValue);
end
end
