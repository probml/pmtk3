function [status,msg] = putRdata(varname,data)
% PUTRDATA Copies MATLAB data to an R variable.
%
%   PUTRDATA(VARNAME,DATA) puts MATLAB variable DATA into R variable
%   VARNAME. Not all R data types are supported by the (D)COM Server.
%   Version 1.2 supports scalars (booleans, integers, doubles and strings)
%   and arrays of these.
%   
%   STATUS = PUTRDATA(VARNAME,DATA) returns true if the data was
%   successfully copied to R.
%
%   [STATUS, MSG] = PUTRDATA(VARNAME, DATA) returns the text of any errors.
%
%   Example:
%
%       status = openR;
%       % Create a MATLAB variable and export it to R.
%       a = 1:10
%       putRdata('a',a)
%
%       % Run a simple R command using the data
%       b = evalR('a^2')
%
%       % Run a series of commands and import the result into MATLAB.
%       evalR('b <- a^2');
%       evalR('c <- b + 1');
%       getRdata('c')
%       % Close the connection.
%       closeR;
%
%   See also: CLOSER, GETRDATA, OPENR, PUTRDATA.

%   Robert Henson, May 2004
%   Copyright 2004 The MathWorks, Inc. 

global R_lInK_hANdle

msg = '';
% Use the SetSymbol method to pass data.
try
    R_lInK_hANdle.SetSymbol(varname,data);
    status = true;
catch
    status = false;
    msg = lasterr;
    if nargout == 0
        error('Could not put data.\n%s',msg);
    end
end
if nargout ==0
    clear status
end

end