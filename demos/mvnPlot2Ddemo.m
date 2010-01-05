%% Plot an MVN in 2D

mu = [0 0]';  S  = [2 1.8; 1.8 2]
%figure; plotPdf(MvnDist(mu,S), '-xrange', [-6 6 -6 6], '-useContour', false); title('full');
%figure; plotPdf(MvnDist(mu,S), '-xrange', [-1 1 -1 1], '-useContour', false); title('full');
figure; plotPdf(MvnDist(mu,S), '-useContour', false); title('full');
printPmtkFigure('gaussPlot2dDemoSurfFull'); 
%figure; plotPdf(MvnDist(mu,S), '-xrange', [-6 6 -6 6], '-useContour', true); title('full');
figure; plotPdf(MvnDist(mu,S), '-useContour', true); title('full');
printPmtkFigure('gaussPlot2dDemoContourFull');

break

% Decorrelate
[U,D] = eig(S);
S1 = U'*S*U
figure; plotPdf(MvnDist(mu,S1), '-xrange', [-5 5 -10 10], '-useContour', false); title('diagonal')
printPmtkFigure('gaussPlot2dDemoSurfDiag'); 
figure; plotPdf(MvnDist(mu,S1), '-xrange', [-5 5 -10 10], '-useContour', true); title('diagonal');
printPmtkFigure('gaussPlot2dDemoContourDiag'); 

% Whiten
A = sqrt(inv(D))*U';
mu2 = A*mu;
S2  = A*S*A' % might not be numerically equal to I
assert(approxeq(S2, eye(2)))
S2 = eye(2); % to ensure picture is pretty
% we plot centered on original mu, not shifted mu
figure; plotPdf(MvnDist(mu,S2), '-xrange', [-5 5 -5 5], '-useContour', false); title('spherical');
printPmtkFigure('gaussPlot2dDemoSurfSpherical'); 
figure; plotPdf(MvnDist(mu,S2), '-xrange', [-5 5 -5 5], '-useContour', true);
title('spherical');axis('equal');
printPmtkFigure('gaussPlot2dDemoContourSpherical');
