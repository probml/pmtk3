function testPmtk3()
%% Minimal test that PMTK3 is correctly installed and working on your system
%
%% matlab Tools

% This file is from pmtk3.googlecode.com

%% Check that initPmtk3 was run 
% It generates a file called 'isOctave.m' that is not preinstalled
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
if 0 %~isOctave && ~verLessThan('matlab', '7.6.0')
    fprintf('Checking for graphviz............');
    try
        graphViz4Matlab();
        close all; 
    catch %#ok
    end
    [j, err] = evalc('system([''dot'','' -V'']);');
    if ~err
        fprintf('PASSED\n');
    else
        fprintf(2, 'FAILED\n'); 
        gvizErr = true; 
        fprintf(2, 'Graphviz, used by some of the demos, (via the <a href="http://graphviz4matlab.googlecode.com">graphViz4Matlab</a> interface)\ncannot be found. You can obtain the latest version from <a href="http://www.graphviz.org/">here</a>.\nAfter installing, please add the "bin" subdirectory to your system path.\n');
    end
end
%% Test code
if isOctave()
  fprintf('warning: pmtk3 has not yet been made fully octave compliant\n')
end

fprintf('Testing selected code............\n\n\n\n');
logregL2FitTest;
newcombDemo
close all
discrimAnalysisDboundariesDemo;
close all
testSprinklerDemo;
close all
hmmDiscreteTest;
knnClassifyDemo;
pcaDemo2d;
close all
kalmanTrackingDemo;
bernoulliBetaSequentialUpdate;
close all;
fprintf('\n.......................\n');
fprintf('\nAll Tests Passed\n');
fprintf('Type runDemos for a more extensive test of the system\n')


end

