function err(ME,message)
    throwAsCaller(addCause(MException('Generic:Error',message),ME));
end