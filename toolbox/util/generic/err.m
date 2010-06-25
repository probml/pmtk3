function err(ME, message)
% Throw an error as the caller with a custom message
throwAsCaller(addCause(MException('Generic:Error', message), ME));
end