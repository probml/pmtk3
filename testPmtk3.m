function testPmtk3()
%% Minimal test that PMTK3 is correctly installed and working on your system
%
%% matlab Tools
fprintf('Checking for matlabTools.........');
if exist('onesPMTK.m', 'file') == 2 && exist('filelist.m', 'file') == 2;
    fprintf('PASSED\n');
else
    fprintf(2, 'FAILED\n\nPMTK3 depends on the matlabTools package,\nwhich is automatically downloaded by initPmtk3.\nPlease try running initPmtk3 again, or download\nthe package manually from <a href = "http://matlabtools.googlecode.com/svn/trunk/matlabTools.zip">here</a>.\n'); 
    return
end
%% Init
fprintf('Checking initialization..........');
initPassed = exist('isOctave.m', 'file') == 2;
if initPassed
    fprintf('PASSED\n');
else
    fprintf(2, 'FAILED\n\nPMTK3 has not been properly initialized\nand may not work correctly. Please try\nrunning initPmtk3() again or report\nthe problem.\n\n') %#ok<PRTCAL>
    return
end
%% PMTK support
%
fprintf('Checking pmtkSupport packages....');
if exist('pmtkSupportRoot.m', 'file') ==  2
    fprintf('PASSED\n');
else
    fprintf(2, 'FAILED\n\nThe PMTK support packages, used by parts of the system\ncannot be found.\n\nPlease download them from <a href = "http://code.google.com/p/pmtksupport/">here</a>,\nand add them to the Matlab path.\n\n');
    return
end
%% PMTK data
%
fprintf('Checking pmtkData................');
try
   loadData('crabs'); 
   fprintf('PASSED\n');
catch %#ok
    fprintf(2, 'FAILED\n\nPMTK data could not be automatically downloaded.\nPlease check your internet connection, and perl installation\nor download the data manually from <a href = "http://code.google.com/p/pmtkdata">here</a>.\n\n');
    return
end
%% graphViz4Matlab
gvizErr = false; 
if ~isOctave && ~verLessThan('matlab', '7.6.0')
    fprintf('Checking for graphviz............');
    
    [j, err] = evalc('system([''dot'','' -V'']);');
    if ~err
        fprintf('PASSED\n');
    else
        fprintf(2, 'FAILED\n'); 
        gvizErr = true; 
    end
end
%% Test code
if isOctave()
  fprintf('warning: pmtk3 has not yet been made fully octave compliant\n')
end

fprintf('Testing selected code............\n\n\n\n');
%try
logregL2FitTest;
newcombDemo
close all
gprDemoNoiseFree;
discrimAnalysisDboundariesDemo;
testSprinklerDemo;
close all
hmmDiscreteTest;
knnClassifyDemo;
pcaDemo2d;
close all
gammaRainfallDemo;
kalmanTrackingDemo;
bernoulliBetaSequentialUpdate;
close all
mcmcMvn2d
close all;
fprintf('\n.......................\n');
if ~gvizErr
    fprintf('\nAll Tests Passed\n');
else
    fprintf('\nAll Tests Passed, except for the following:\n');
    fprintf(2, 'Graphviz, used by some of the demos, (via the <a href="http://graphviz4matlab.googlecode.com">graphViz4Matlab</a> interface)\ncannot be found. You can obtain the latest version from <a href="http://www.graphviz.org/">here</a>.\nAfter installing, please add the "bin" subdirectory to your system path.\n');
end
fprintf('\n.......................\n');
    

end

