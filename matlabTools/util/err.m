function err(ME, message)
% Throw an error as the caller with a custom message

% This file is from pmtk3.googlecode.com

throwAsCaller(addCause(MException('Generic:Error', message), ME));
end
