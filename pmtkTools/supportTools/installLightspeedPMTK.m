%% Compiles mex files for the lightspeed library.

% This file is from pmtk3.googlecode.com


% Written by Tom Minka
% (c) Microsoft Corporation. All rights reserved.

% thanks to Kevin Murphy for suggesting this routine.
% thanks to Ruben Martinez-Cantin for UNDERSCORE_LAPACK_CALL
%
% PMTKmodified Matt Dunham
% This has been modified from the version that ships to only compile a
% subsection of files. Further, it only runs if it detects that lightspeed
% is not installed.
%PMTKneedsMatlab
%%

directory = fullfile(pmtkSupportRoot, getConfigValue('PMTKlightSpeedDir'));
if ~exist(directory, 'dir'), return; end
if exist('randgamma', 'file') == 3, return; end
cd(directory);
fprintf('Compiling lightspeed mex files...\n');


% Matlab version
v = sscanf(version,'%d.%d.%*s (R%d) %*s');
% v(3) is the R number
% could also use v(3)>=13
atleast65 = (v(1)>6 || (v(1)==6 && v(2)>=5));
atleast75 = (v(1)>7 || (v(1)==7 && v(2)>=5));
atleast76 = (v(1)>7 || (v(1)==7 && v(2)>=6));
atleast78 = (v(1)>7 || (v(1)==7 && v(2)>=8));


% these are done first to initialize mex
mex -c flops.c
mex sameobject.c
mex int_hist.c
mex -c mexutil.c
mex -c util.c

libdir = '';
if ispc
    [compiler,libloc,vsinstalldir,vcvarsopts] = mexcompiler;
    libdir = fullfile(matlabroot,libloc);
    engmatopts = [compiler 'engmatopts.bat'];
end


% Routines that use LAPACK
lapacklib = '';
blaslib = '';
flags = '';
if ispc
    if strncmp(compiler,'MSVC',4)
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
    % in version 7.5, non-PC systems do not need to specify lapacklib,
    % but they must use an underscore when calling lapack routines
    % http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/f13120.html#f45091
    flags = '-DUNDERSCORE_LAPACK_CALL';
    if atleast76
        lapacklib = '-lmwlapack';
        blaslib = '-lmwblas';
    end
end
eval(['mex ' flags ' solve_triu.c "' lapacklib '" "' blaslib '"']);
eval(['mex ' flags ' solve_tril.c "' lapacklib '" "' blaslib '"']);

if ispc
    % Windows
    %if exist('util.obj','file')
    mex addflops.c flops.obj
    %mex gammaln.c util.obj -largeArrayDims
    mex digamma.c util.obj -largeArrayDims
    mex trigamma.c util.obj -largeArrayDims
    mex tetragamma.c util.obj -largeArrayDims
    mex setnonzeros.c -largeArrayDims
    if strncmp(compiler,'MSVC',4)
        clear random.dll randomseed randbinom randgamma sample_hist
        disp(['install_random.bat "' vsinstalldir '" ' vcvarsopts]);
        system(['install_random.bat "' vsinstalldir '" ' vcvarsopts]);
        mex randomseed.c util.obj random.lib
        mex randbinom.c mexutil.obj util.obj random.lib
        mex randgamma.c mexutil.obj util.obj random.lib
        mex sample_hist.c util.obj random.lib
    else
        fprintf('mexcompiler is not MSVC. The randomseed() function will have no effect.');
        mex randomseed.c util.obj random.c
        mex randbinom.c mexutil.obj util.obj random.c
        mex randgamma.c mexutil.obj util.obj random.c
        mex sample_hist.c util.obj random.c
    end
    %mex repmat.c mexutil.obj
    %   try
    %     % standalone programs
    %     % compilation instructions are described at:
    %     % http://www.mathworks.com/access/helpdesk/help/techdoc/matlab_external/ch1_im15.html#27765
    %     if atleast78
    % 			disp('lightspeed''s matfile utility is not supported for this version of Matlab');
    % 		elseif atleast65
    %       % -V5 is required for Matlab >=6.5
    %       mex('-f',engmatopts,'matfile.c','-V5');
    %     else
    %       mex('-f',engmatopts,'matfile.c');
    %     end
    %     % uncomment the line below if you want to build test_flops.exe
    %     % This program lets you check the flop counts on your processor.
    %     % mex('-f',engmatopts,'tests/test_flops.c');
    %   catch
    %     disp('Could not install the standalone programs.');
    %     disp(lasterr)
    %   end
else
    % UNIX
    mex addflops.c flops.o
    %mex gammaln.c util.o -lm -largeArrayDims
    mex digamma.c util.o -lm -largeArrayDims
    mex trigamma.c util.o -lm -largeArrayDims
    mex tetragamma.c util.o -lm -largeArrayDims
    mex setnonzeros.c -largeArrayDims
    if ismac
        % thanks to Nicholas Butko for these mac-specific lines
        clear librandom.dylib randomseed randbinom randgamma sample_hist
        system('cc -fPIC -O -c random.c; cc -dynamiclib -Wl,-install_name,`pwd`/librandom.dylib -o librandom.dylib random.o')
        mex randomseed.c util.o librandom.dylib -lm
        mex randbinom.c mexutil.o util.o librandom.dylib -lm
        mex randgamma.c mexutil.o util.o librandom.dylib -lm
        mex sample_hist.c util.o librandom.dylib -lm
    else
        % this command only works on linux
        clear librandom.so randomseed randbinom randgamma sample_hist
        system('cc -fPIC -O -c random.c; cc -shared -Wl,-E -Wl,-soname,`pwd`/librandom.so -o librandom.so random.o')
        mex randomseed.c util.o librandom.so -lm
        mex randbinom.c mexutil.o util.o librandom.so -lm
        mex randgamma.c mexutil.o util.o librandom.so -lm
        mex sample_hist.c util.o librandom.so -lm
    end
    %mex repmat.c mexutil.o
    %   try
    %     % standalone programs
    %     if atleast78
    % 			disp('lightspeed''s matfile utility is not supported for this version of Matlab');
    % 		elseif atleast65
    %       % -V5 is required only for Matlab >=6.5
    %       mex -f matopts.sh matfile.c -V5
    %     else
    %       mex -f matopts.sh matfile.c
    %     end
    %     % uncomment the line below if you want to build test_flops.exe
    %     % This program lets you check the flop counts on your processor.
    %     % mex -f matopts.sh tests/test_flops.c
    %   catch
    %     disp('Could not install the standalone programs.');
    %     disp(lasterr);
    %     fprintf('Note: if matlab cannot find matopts.sh, your installation of matlab is faulty.\nIf you get this error, don''t worry, lightspeed should still work.');
    %   end
end

%addpath(genpath(pwd))
fprintf('Done.\n');
%fprintf('Type "test_lightspeed" to verify the installation.\n');
