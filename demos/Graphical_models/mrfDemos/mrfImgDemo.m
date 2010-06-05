%% Demonstrate inference  in a 2d grid of a noisy image of an X
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/graphCuts.html

%% Get model and data
setSeed(0);
[model, Xclean, X] = mkXlatticeMrf();
[nRows, nCols] = size(Xclean);

figure; imagesc(Xclean); colormap('gray');
title('clean'); printPmtkFigure('mrfImgClean')

figure; imagesc(X); colormap('gray');
title('noisy');printPmtkFigure('mrfImgNoisy')

%% Independent Decoding
[junk IndDecoding] = max(model.nodePot,[],2);
figure; imagesc(reshape(IndDecoding,nRows,nCols));
 colormap gray; title('Independent Decoding');
printPmtkFigure('mrfImgIndep')

estMethods = {'GraphCut', 'ICM', 'ICMrestart', 'Gibbs'};
estMethodArgs ={ {}, {}, {}, {100} };

%% graphcuts
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/graphCuts.html
[model] = mkXlatticeMrf('GraphCut');
optimalDecoding = mrfEstJoint(model);
energyGC = mrfEnergy(model, optimalDecoding);
figure; imagesc(reshape(optimalDecoding,nRows,nCols));
colormap gray;
title(sprintf('graph cuts, E=%8.5f', energyGC));
printPmtkFigure('mrfImgGraphcuts')

%% ICM
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/ICM.html
[model] = mkXlatticeMrf('ICM');
ICMDecoding = mrfEstJoint(model);
energyICM = mrfEnergy(model, ICMDecoding);
figure; imagesc(reshape(ICMDecoding,nRows,nCols));
colormap gray; 
title(sprintf('ICM, E=%8.5f', energyICM));
printPmtkFigure('mrfImgIcm')

%% ICM with restarts
% Based on http://www.cs.ubc.ca/~schmidtm/Software/UGM/ICM.html
Nrestarts = 100;
[model] = mkXlatticeMrf('ICMrestart', {Nrestarts});
ICMDecodingR = mrfEstJoint(model);
energyICMR = mrfEnergy(model, ICMDecodingR);
figure; imagesc(reshape(ICMDecodingR,nRows,nCols));
colormap gray;
title(sprintf('ICM with %d restarts, E=%8.5f', Nrestarts, energyICMR));
printPmtkFigure('mrfImgIcmRestarts')



