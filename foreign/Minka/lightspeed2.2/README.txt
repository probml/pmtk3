This is a library of efficient and useful matlab functions, with an
emphasis on statistics.
See Contents.m for a synopsis.

You can place the lightspeed directory anywhere.
To make sure lightspeed is always in your path, create a startup.m
file in your matlab directory, if you don't already have one, and add
a line like this:
  addpath(genpath('c:\matlab\lightspeed'))
Replace 'c:\matlab\lightspeed' with the location of the lightspeed directory.

There are some Matlab Extension (MEX) files that need to be compiled.
This can be done in matlab via:
  cd c:\matlab\lightspeed
  install_lightspeed

If you are using Matlab 7.0 (R14) and Microsoft Visual C++ as your compiler 
(my recommended compiler), then you will need to download a patch:
http://www.mathworks.com/support/solutions/data/1-QK7PM.html?solution=1-QK7PM
Place the file in $MATLAB/extern/lib/win32/microsoft/libmwlapack.lib
where $MATLAB is your root MATLAB directory.

You can find timing tests in the tests/ subdirectory.  
The test_lightspeed.m script will run all tests, and is a good way to check 
that lightspeed installed properly.


Tom Minka
