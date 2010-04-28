function [data,status,msg] = getRdata(varname)
% GETRDATA Copies an R variable to MATLAB.
%
%   DATA = GETRDATA(VARNAME) gets the contents of R variable VARNAME.
%
%   [DATA, STATUS] = GETRDATA(VARNAME) returns true if the data was
%   successfully imported from R.
%
%   [DATA, STATUS, MSG] = GETRDATA(VARNAME) returns the text of any errors.
%
%   Example:
%
%       status = openR;
%       % Create a MATLAB variable and export it to R.
%       a = 1:10;
%       putRdata('a',a);
%       % Run a simple R command using the data
%       b = evalR('a^2')
%       % Run a series of commands and import the result into MATLAB.
%       evalR('b <- a^2');
%       evalR('c <- b + 1');
%       c = getRdata('c')
%       % Close the connection.
%       evalR('data(volcano)');
%       volcano = getRdata('volcano');
%       imagesc(volcano);
%       closeR;
%
%   See also: CLOSER, GETRDATA, OPENR, PUTRDATA.

%   Robert Henson, May 2004
%   Copyright 2004 The MathWorks, Inc. 

global R_lInK_hANdle

msg = '';
% get data using the handle.GetSymbol method. 
try
    data = R_lInK_hANdle.GetSymbol(varname);
    status = true;
catch
    % errors from the server can be quite cryptic...
    data = [];
    status = false;
    msg = lasterr;
    if nargout == 0
        error('Could not get %s.\n%s',varname,msg);
    end
end
end