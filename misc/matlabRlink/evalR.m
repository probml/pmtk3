function [result,status,msg] = evalR(command,noreturn)
%EVALR Run an R command.
%
%   RESULT = EVALR(COMMAND) evaluates R command COMMAND and saves the
%   output of the command in RESULT.   
%
%   [RESULT,STATUS] = EVALR(COMMAND) returns true if the command executed
%   without error, false otherwise.
%
%   [RESULT, STATUS, MSG] = EVALR(COMMAND) returns any error messages.
%
%   [RESULT, STATUS, MSG] = EVALR(COMMAND, 0) is used to get the
%   status when executing R commands such as sourcing files or running
%   demos that do not return any result. 
%
%   Example:
%
%       status = openR;
%       % Generate some random numbers.
%       x  = evalR('runif(5)')
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
%       closeR;
%
%   See also: CLOSER, GETRDATA, OPENR, PUTRDATA.

%   Robert Henson, May 2004
%   Copyright 2004 The MathWorks, Inc. 

global R_lInK_hANdle
result = [];
msg = '';

% For some reason there are two methods for evaluating commands -- Evaluate
% and EvaluateNoReturn. These seem to do the right thing until the output
% handling is reached at which point EvaluateNoReturn errors if outputs
% were requested and Evaluate errors if no outputs were returned. 

try
    if nargout == 0 || (nargin == 2 && noreturn == 0)
        R_lInK_hANdle.EvaluateNoReturn(command);
    else
        result = R_lInK_hANdle.Evaluate(command);
    end
    status = true;
catch
    status = false;
    msg = lasterr;
    if nargout == 0
        error('Problem evaluating command %s.\n%s',command,msg);
    end
end

if nargout == 0
    clear result;
end

end