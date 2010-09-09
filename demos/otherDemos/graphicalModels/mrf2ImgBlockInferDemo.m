%% Demonstrate block-based inference  in a 2d grid of a noisy image of an X
% Based on
% http://www.cs.ubc.ca/~schmidtm/Software/UGM/block.html
% PMTKslow
%% Get model and data

% This file is from pmtk3.googlecode.com

setSeed(0);
load X.mat % binary image of an 'X'
Xclean = X;
X = Xclean + 0.5*randn(size(Xclean));
[nRows, nCols] = size(Xclean);

figure; imagesc(Xclean); colormap('gray');
title('clean'); 

figure; imagesc(X); colormap('gray');
title('noisy');

blocks = mrf2ImgMkTwoBlocks(nRows, nCols);


%% MAP estimation

methods = {};
methodArgs = {};

methods{end+1} = 'ICM';
methodArgs{end+1} = {'nRestarts', 1};

methods{end+1} = 'Block_ICM';
methodArgs{end+1} = {'blocks', blocks};

for i=1:length(methods)
  method = methods{i};
  args = methodArgs{i};
  [model] = mrf2MkLatticeX(X, method, args);
  zhat = mrf2Map(model);
  energy = mrf2Energy(model, zhat);
  figure; imagesc(reshape(zhat,nRows,nCols));
  colormap gray;
  title(sprintf('MAP estimate using %s, E=%5.3f', method, energy));
  printPmtkFigure(sprintf('mrfImgEst%s', method))
end


%% Inference


methods = {};
methodArgs = {};

methods{end+1} = 'MeanField';
methodArgs{end+1} = {'maxIter', 100};

methods{end+1} = 'Block_MF';
methodArgs{end+1} = {'blocks', blocks, 'maxIter', 100};

methods{end+1} = 'Gibbs';
methodArgs{end+1} = {'burnIn', 100, 'nSamples', 100};


methods{end+1} = 'Block_Gibbs'; % slow
methodArgs{end+1} = {'blocks', blocks, 'burnIn', 10, 'nSamples', 10};



for i=1:length(methods)
  method = methods{i};
  args = methodArgs{i};
  [model] = mrf2MkLatticeX(X, method, args);
  
  [nodeBel]  = mrf2InferNodesAndEdges(model);
  p1 = nodeBel(:,2);  
  figure; imagesc(reshape(p1,nRows,nCols)); colormap gray;
  title(sprintf('mean of marginals using %s', method));
  printPmtkFigure(sprintf('mrfImgMeanOfMarginals%s', method))
  
  [junk zhat] = max(nodeBel,[],2);
  figure; imagesc(reshape(zhat,nRows,nCols)); colormap gray;
  title(sprintf('max of marginals using %s', method));
  printPmtkFigure(sprintf('mrfImgMaxOfMarginals%s', method))
end


