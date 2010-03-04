function [status,msg] = closeR(handle)
%CLOSER Close connection to R server process
%
%   STATUS = CLOSER closes an R server process. STATUS is set to true if
%   the disconnection was successful, false otherwise.
%
%   [STATUS, MSG] = CLOSER returns any warning messages in the output MSG
%   and does not throw warnings.
%
%   CLOSER(HANDLE) closes the connection associated with handle HANDLE.
%
%   Example:
%      
%       status = openR;
%       % Run one of the R demos to test the connection.
%       evalR('demo("persp")');
%       % Close the connection.
%       closeR;
%
%   See also:  EVALR, GETRDATA, OPENR, PUTRDATA.

%   Robert Henson, May 2004
%   Copyright 2004 The MathWorks, Inc. 

global R_lInK_hANdle

msg = '';
status = false;
% Check that we have a session to close.
if nargin == 0
    if isempty(R_lInK_hANdle)

        if nargout ==0
            error('No open R sessions to close.');
        else
            msg = 'No open R sessions to close.';
        end
    else
        handle = R_lInK_hANdle;
    end
end
% Close the connection and free the handle.
try
    handle.Close;
    status = true;
    if isequal(handle,R_lInK_hANdle)
        R_lInK_hANdle = [];
    end
catch
    if nargout ==0
        error('Cannot close R session.\n%s',lasterr);
    else
        msg = lasterr;
    end

end

if nargout ==0
    clear status;
end

end