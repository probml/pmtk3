Probabilistic modeling toolkit version 3
See pmtk3.googlecode.com for details.


This version (28 Feb 2011) has been tested (in the weak sense that the
'runDemos' command runs to completion) on the 
configurations described below,
where we use the following abbreviations:

 +- opt : including / excluding Mathworks optimization toolbox
 +- stats : including / excluding Mathworks statistics toolbox
 +- image : including / excluding Mathworks image processing toolbox
 +- bio : including / excluding Mathworks bioinformatics toolbox
 +- gviz:  including / excluding graphviz
 +- libdai:  including / excluding libdai 
 +- glmnet:  including / excluding glmnet (Fortran library not
 available for maci64)
 +- libsvm:  including / excluding libsvm (Matlab inferface)
 +- UGM:  including / excluding Mark Schmidt's UGM package

(If packages are missing, some demos may be skipped.)

Some supporting packages have not been compiled for certain architectures.

Extensions for binary filetypes
http://www.mathworks.com/help/techdoc/matlab_external/f29502.html#bra56dy-1
- mexglx     32 bit linux
- mexa64     64 bit linux
- mexmaci64  64 bit mac
- mexw32     32 bit MS windows
- mexw64     64 bit MS windows

1. Windows 7 professional, Matlab 2010a, +opt, +stats, +bio, +image,
+gviz, +libdai, +glmnet, +libsvm, +UGM

2. MAC OS X 10.6.4, Matlab 7.10.0 2010a, -opt, +stats, -bio, +image,
-gviz, -libdai, -glmnet, -libsvm, +UGM

3. Ubuntu linux 10.04, Matlab 7.10.0 2010a, -opt, +stats, -bio, +image,
-gviz, -libdai, +glmnet, -libsvm, +UGM