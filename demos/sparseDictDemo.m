%% Learn a sparse dictionary from image patches
%PMTKauthor Julien Mairal
%PMTKmodified Kevin Murphy
% Needs SPAMS, available from http://www.di.ens.fr/willow/SPAMS/

% This file is from pmtk3.googlecode.com


%PMTKslow

clear all;
methods = {'SPCA1', 'SPCA2', 'SC', 'PCA', 'NMF'};
%methods = {'SC'};
p=64; % number of basis vectors

if 1
  loadFolder('pmtkImages') % for lena
  I=double(imread('lena.png'))/255;
  %X=mexExtractPatches(I,12);
  X=im2col(I,[12 12],'sliding'); % 144*251,001
  X = X(:, 1:100000);  % save some space
else
  X = loadData('facesCBCL'); % 19*19*2429
  [nr nc N] = size(X);
  X = reshape(X, [nr*nc N]);
end
Xraw = X;

for i=1:numel(methods)
  method = methods{i};
  
  % Data preprocessing
  X = Xraw;
  if (~strcmpi(method,'nmf')) % data must be positive for NMF
    %X=X-repmat(mean(X),[size(X,1) 1]);
    X = centerCols(X);
  end
  %X=X ./ repmat(sqrt(sum(X.^2)),[size(X,1) 1]);
  X = mkUnitNorm(X);
  
  % Dictionary learning
  disp(method)
  clear param % ensure we use defaults
  tic
  if (strcmpi(method,'pca'))
    [U S V]=svd(X,'econ');
    D=U(:,1:p);
  else
    param.K=p;
    param.batchsize=256; % 512;
    param.iter=500; % 1000
    param.numThreads=-1; % uses all the cores
    param.verbose=false;
    switch lower(method)
      case 'nmf'
        D=nmf(X,param);
      case {'sc', 'dl'}
        param.lambda=0.1;
        param.mode=2;
        D=mexTrainDL(X,param);
      case 'spca1'
        param.modeD=1;
        param.lambda=0.1;  
        param.gamma1=0.1; 
        D=mexTrainDL(X,param);
      case 'spca2'
        param.modeD=1;
        param.lambda=0.1;
        param.gamma1=0.2;
        D=mexTrainDL(X,param);
    end
  end
  toc
  
  figure
  %Im=displayPatches(D); % 4.0 is a contrast factor
  plotPatches(D);
  %title(method)
  drawnow
  printPmtkFigure(sprintf('sparseDictDemo%s', method))
end
