function testPmtk3()
%% Minimal test that PMTK3 is correctly installed and working on your system
%
%% Paths
fprintf('Checking PMTK3 paths.............');
if exist('onesPMTK.m', 'file') == 2 && exist('filelist.m', 'file') == 2;
    fprintf('PASSED\n');
else
    fprintf(2, 'FAILED\n\nPMTK3 has not been fully added to the MATLAB path\nand may not work correctly.\nPlease try running initPmtk3() again or report the problem.\n\n') %#ok<PRTCAL>
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
if ~isOctave
    fprintf('Checking for graphviz............');
    
    [j, err] = evalc('system([''dot'','' -V'']);');
    if ~err
        fprintf('PASSED\n');
    else
        fprintf(2, 'FAILED\n\nGraphviz, used by the associated graphViz4Matlab package,\ncannot be found. Please install it from <a href="http://http://www.graphviz.org/">here</a>,\nand add the bin subdirectory to your system path.\n');
        return
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
mixGaussFitEm(loadData('faithful'), 2);
demoSteepestDescentRosen;
close all
gammaRainfallDemo;
kalmanTrackingDemo;
bernoulliBetaSequentialUpdate;
close all
mcmcMvn2d
close all;
fprintf('\n.......................\n');
fprintf('\nAll Tests Passed\n');
fprintf('\n.......................\n');

end








