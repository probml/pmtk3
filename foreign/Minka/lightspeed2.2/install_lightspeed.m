%Install_lightspeed
% Compiles mex files for the lightspeed library.

% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

% thanks to Kevin Murphy for suggesting this routine.
% thanks to Ruben Martinez-Cantin for UNDERSCORE_LAPACK_CALL


fprintf('Compiling lightspeed mex files...\n');


% Matlab version
v = sscanf(version,'%d.%d.%*s (R%d) %*s');
% v(3) is the R number
% could also use v(3)>=13
atleast65 = (v(1)>6 || (v(1)==6 && v(2)>=5));
atleast75 = (v(1)>7 || (v(1)==7 && v(2)>=5));

% copy matlab's original repmat.m as xrepmat.m
if exist('xrepmat.m') ~= 2
  %w = which('repmat','-all');
  %w = w{end};
  w = fullfile(matlabroot,'toolbox\matlab\elmat\repmat.m');
  cmd = ['"' w '" xrepmat.m'];
  if ispc
    system(['copy ' cmd]);
  else
    system(['cp -rp ' cmd]);
  end
end

% these are done first to initialize mex
mex -c flops.c
mex sameobject.c
mex int_hist.c
mex -c mexutil.c
mex -c util.c

libdir = '';
if ispc
  if strcmp(mexcompiler,'cl')
    libdir = fullfile(matlabroot,'extern\lib\win32\microsoft');
  else
    libdir = fullfile(matlabroot,'extern\lib\win32\lcc');
  end
end


% Routines that use LAPACK
lapacklib = '';
blaslib = '';
flags = '';
if ispc
  if strcmp(mexcompiler,'cl')
    if atleast65
      % version >= 6.5
      lapacklib = fullfile(libdir,'libmwlapack.lib');
    end
  else
    lapacklib = fullfile(libdir,'libmwlapack.lib');
  end
  if atleast75
    blaslib = fullfile(libdir,'libmwblas.lib');
  end
  %%% Paste the location of libmwlapack.lib %%%
  %lapacklib = '';
  if ~exist(lapacklib,'file')
    lapacklib = 'dtrsm.c';
    fprintf('libmwlapack.lib was not found.  To get additional optimizations, paste its location into install_lightspeed.m\n');
  else
    fprintf('Using the lapack library at %s\n',lapacklib);
  end
else
  % non-PC systems do not need to specify lapacklib, 
  % but they must use an underscore when calling lapack routines
  % http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f13120.html#f45091
  flags = '-DUNDERSCORE_LAPACK_CALL';
end
eval(['mex ' flags ' solve_triu.c "' lapacklib '" "' blaslib '"']);
eval(['mex ' flags ' solve_tril.c "' lapacklib '" "' blaslib '"']);

if ispc
  % Windows
  %if exist('util.obj','file')
  mex addflops.c flops.obj
  mex digamma.c util.obj
  mex gammaln.c util.obj
  if strcmp(mexcompiler,'cl')
    system('install_random.bat');
    mex randomseed.c util.obj random.lib
    mex randbinom.c util.obj random.lib
    mex randgamma.c util.obj random.lib
    mex sample_hist.c util.obj random.lib
  else
    fprintf('mexcompiler is not cl. The randomseed() function will have no effect.');
    mex randomseed.c util.obj random.c
    mex randbinom.c util.obj random.c
    mex randgamma.c util.obj random.c
    mex sample_hist.c util.obj random.c
  end
  %mex repmat.c mexutil.obj
  mex trigamma.c util.obj
  try
    % standalone programs
    % compilation instructions are described at:
    % http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/ch1_im15.html#27765
    if atleast65
      % -V5 is required for Matlab >=6.5
      mex -f lccengmatopts.bat matfile.c -V5
      %mex -f msvc71engmatopts.bat matfile.c -V5
    else
      mex -f lccengmatopts.bat matfile.c
    end
    % uncomment the line below if you want to build test_flops.exe
    % This program lets you check the flop counts on your processor.
    % mex -f lccengmatopts.bat tests/test_flops.c
  catch
    disp('Could not install the standalone programs.');
    disp(lasterr)
  end
else
  % UNIX
  mex addflops.c flops.o
  mex digamma.c util.o -lm
  mex gammaln.c util.o -lm
  % this command only works on linux
  system('cc -fPIC -O -c random.c; cc -shared -Wl,-E -Wl,-soname,`pwd`/librandom.so -o librandom.so random.o')
  mex randomseed.c util.o librandom.so -lm
  mex randbinom.c util.o librandom.so -lm
  mex randgamma.c util.o librandom.so -lm
  mex sample_hist.c util.o librandom.so -lm
  mex repmat.c mexutil.o
  mex trigamma.c util.o -lm
  try
    % standalone programs
    if atleast65
      % -V5 is required only for Matlab >=6.5
      mex -f matopts.sh matfile.c -V5
    else
      mex -f matopts.sh matfile.c
    end  
    % uncomment the line below if you want to build test_flops.exe
    % This program lets you check the flop counts on your processor.
    % mex -f matopts.sh tests/test_flops.c
  catch
    disp('Could not install the standalone programs.');
    disp(lasterr);
    fprintf('Note: if matlab cannot find matopts.sh, your installation of matlab is faulty.\nIf you get this error, don''t worry, lightspeed should still work.');
  end
end

addpath(genpath(pwd))
fprintf('Done.\n');
%fprintf('Type "test_lightspeed" to verify the installation.\n');
