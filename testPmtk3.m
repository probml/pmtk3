function testPmtk3()
%% Test that PMTK3 is correctly installed and working on your system
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

%% graphViz4Matlab
if ~isOctave
    fprintf('Checking for graphViz4Matlab.....' );
    if exist('drawNetwork.m', 'file') ==  2
        fprintf('PASSED\n');
    else
        fprintf(2, 'FAILED\n\ngraphViz4Matlab, used by parts of the system\ncannot be found.\nPlease download it from <a href = "http://code.google.com/p/graphviz4matlab/">here</a>.\n\n');
        return
    end
end
%% Test code
if ~isOctave() % We're not quite ready for Octave
    fprintf('Testing selected code............\n\n\n\n');
    try
        linregFitTestSimple;
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
        mixGaussFitEm(loadData('faithful'), 2, 'verbose', true);
        mlpRegressDemoBishop;
        demoSteepestDescentRosen;
        close all
        gammaRainfallDemo;
        kalmanTrackingDemo;
        bernoulliBetaSequentialUpdate;
        close all
        mcmcMvn2d
        close all;
        fprintf('\n\nTesting selected code............PASSED\n\n\n\n');
    catch
        close all;
        clc;
        fprintf(2, 'One or more test demos did not run\ncorrectly, please report the problem.\n\n');
        return
    end
    
    fprintf('\nALL TESTS PASSED\n\n');
    
end


end








