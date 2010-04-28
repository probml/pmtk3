%% Connecting MATLAB to R 
% The statistical programming language R has a COM interface. We can use
% this to execute R commands from within MATLAB.

%% Connect to an R Session
openR

%% Push data into R
a = 1:10;
putRdata('a',a)

%% Run a simple R command
b = evalR('a^2')

%% Run a series of commands and grab the result
evalR('b <- a^2');
evalR('c <- b + 1');
c = getRdata('c')

%% Close the connection
closeR
