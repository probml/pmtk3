function [status ,msg, handle] = openR
%OPENR Connect to an R server process.
%
%   STATUS = OPENR connects to an R server process. If there is an existing
%   R server process a warning will be given. STATUS is set to true if
%   the connection was successful, false otherwise.
%
%   [STATUS, MSG] = OPENR returns any error or warning messages in the
%   output MSG and does not throw warnings. Note that error messages from
%   the server can by quite cryptic.
%
%   [STATUS, MSG, HANDLE] = OPENR returns the handle of the R COM server
%   connection.
%
%   The connection to R is made via the R (D)COM Server. This can be
%   downloaded from http://cran.au.r-project.org/contrib/extra/dcom or
%   other CRAN mirror sites. These functions were tested with version 1.2
%   of the (D)COM Server. Not all R data types are supported by the (D)COM
%   Server. Version 1.2 supports scalars (booleans, integers, doubles and
%   strings) and arrays of these.
%
%   Example:
%
%       status = openR;
%       % Run one of the R demos to test the connection.
%       evalR('demo("persp")');
%       % Now copy the volcano data into MATLAB
%       volcano = getRdata('volcano');
%       % Use SURF to plot the volcano
%       surf(volcano);
%       axis off; view(-135,40);
%       % You can also copy the colormap from R
%       cols = char(evalR('terrain.colors(20)'));
%       red = hex2dec(cols(:,[2 3]));
%       green = hex2dec(cols(:,[4 5]));
%       blue = hex2dec(cols(:,[6 7]));
%       colormap([red,green,blue]/256);
%       % Close the connection.
%       closeR;
%
%   See also: CLOSER, EVALR, GETRDATA, PUTRDATA.

%   Robert Henson, May 2004
%   Copyright 2004 The MathWorks, Inc.

status = false;
msg = '';

% Use a global variable to keep track of the connection handle.
global R_lInK_hANdle

% Check if a connection exists
if ~isempty(R_lInK_hANdle)
    msg = 'Already connected to an R server.';
    if nargout < 2
        warning(msg);
    end
else
    % if not, call the StatConnector and initialize an R session
    try
        R_lInK_hANdle = actxserver('StatConnectorSrv.StatConnector');
        R_lInK_hANdle.Init('R');
        status = true;
    catch
        status = false;
        R_lInK_hANdle = [];
        if nargout == 0
            error('Cannot connect to R.\n%s',lasterr);
        else
            msg = lasterr;
        end
    end
end
% deal with outputs
if nargout > 2
    handle = R_lInK_hANdle;
end
if nargout ==0
    clear status
end

end