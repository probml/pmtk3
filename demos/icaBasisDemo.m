function icaBasisDemo()
% Apply ICA to natural image patches and visualize basis functions

% This file is from pmtk3.googlecode.com


% Extracted from figures.m which is the file that 
% accompanies
%"Natural Image Statistics" by Hyvarinen, Hurri, and Hoyer.
% Used with permission of Aapo Hyvarinen

%PMTKauthor  Aapo Hyvarinen
%PMTKslow % about 80 seconds

%imgFolder= 'C:\kmurphy\Books\aapoBook\data';
loadFolder('hyvarinenBookImages')
imgFolder = [];

setSeed(0);

%sample size, i.e. how many image patches. Book value: 50000
samplesize=10000; 
%patchsize in most experiments. Book value: 32
patchsize=32;
%Number of features or weight vectors in one column in the big plots
%Book value: 16
plotcols=8; % 16; 
%Number of features computed, i.e. PCA dimension in big experiments
%Book value: plotcols*16, or 256
rdim=plotcols*8; % plotcols*16; 

%Choose "small" value which determines when the change in estimate is so small
%that algorithm can be stopped. 
%This is related to the proportional change allowed for the features
%Book value: 1e-4, i.e. accuracy must be of the order of 0.01%
global convergencecriterion  
convergencecriterion=1e-4;

%define default colormap
colormap('gray')


%Sample data and preprocess
disp('Sampling data')
X=sampleimages(samplesize,patchsize, imgFolder);
disp('Removing DC component')
X=removeDC(X);
disp('Doing PCA and whitening data')
[V,E,D]=pca(X);
Z=V(1:rdim,:)*X;

tic
W=ica(Z,rdim); 
toc

%transform back to original space from whitened space
Wica = W*V(1:rdim,:);
%Compute A using pseudoinverse (inverting canonical preprocessing is tricky)
Aica=pinv(Wica);

figure
plotPatches(Aica,plotcols)  %This is Figure 7.3
%title('generative weights from ICA')
printPmtkFigure('icaBasisGen')

figure
plotPatches(Wica',plotcols) %This is Figure 6.6
%title('recognition weights from ICA')
printPmtkFigure('icaBasisRec')

end




function X = sampleimages(samples, winsize, folder)

% gathers patches from the grey-scale images, no preprocessing done yet
%
% INPUT variables:
% samples            total number of patches to take
% winsize            patch width in pixels
%
% OUTPUT variables:
% X                  the image patches as column vectors


  


%----------------------------------------------------------------------
% Gather rectangular image patches
%----------------------------------------------------------------------

% We have a total of 13 images.
dataNum = 13;

% This is how many patches to take per image
getsample = floor(samples/dataNum);

% Initialize the matrix to hold the patches
X = zeros(winsize^2,samples);

sampleNum = 1;  
for i=(1:dataNum)

  % Even things out (take enough from last image)
  if i==dataNum, getsample = samples-sampleNum+1; end
  
  % Load the image. Change the path here if needed.
  
  %I = imread(fullfile(folder, sprintf('%d.tiff', i)));
  I = imread(fullfile(sprintf('%d.tiff', i)));

  % Transform to double precision
  I = double(I);

  % Normalize to zero mean and unit variance (optional)
  I = I-mean(mean(I));
  I = I/sqrt(mean(mean(I.^2)));
  
  % Sample patches in random locations
  sizex = size(I,2); 
  sizey = size(I,1);
  posx = floor(rand(1,getsample)*(sizex-winsize-2))+1;
  posy = floor(rand(1,getsample)*(sizey-winsize-1))+1;
  for j=1:getsample
    X(:,sampleNum) = reshape( I(posy(1,j):posy(1,j)+winsize-1, ...
			posx(1,j):posx(1,j)+winsize-1),[winsize^2 1]);
    sampleNum=sampleNum+1;
  end 
  
end

end


function W=ica(Z,n)
%Simple code for ICA of images
%Aapo Hyvärinen, for the book Natural Image Statistics

global convergencecriterion

%------------------------------------------------------------
% input parameters settings
%------------------------------------------------------------
%
% Z                     : whitened image patch data
%
% n = 1..windowsize^2-1 : number of independent components to be estimated


%------------------------------------------------------------
% Initialize algorithm
%------------------------------------------------------------

%create random initial value of W, and orthogonalize it
W = orthogonalizerows(randn(n,size(Z,1))); 

%read sample size from data matrix
N=size(Z,2);

%------------------------------------------------------------
% Start algorithm
%------------------------------------------------------------

disp('Doing FastICA. Iteration count: ')

iter = 0;
notconverged = 1;
maxIter = 2000 % about 0.5s per iter with 10k 32*32 patches
while notconverged && (iter<maxIter) 

  iter=iter+1;
  
  %print iteration count
  writenum(iter);
  
  % Store old value
  Wold=W;        

  %-------------------------------------------------------------
  % FastICA step
  %-------------------------------------------------------------  

    % Compute estimates of independent components 
    Y=W*Z; 
 
    % Use tanh non-linearity
    gY = tanh(Y);
    
    % This is the fixed-point step. 
    % Note that 1-(tanh y)^2 is the derivative of the function tanh y
    W = gY*Z'/N - (mean(1-gY'.^2)'*ones(1,size(W,2))).*W;    
    
    % Orthogonalize rows or decorrelate estimated components
    W = orthogonalizerows(W);

  % Check if converged by comparing change in matrix with small number
  % which is scaled with the dimensions of the data
  if norm(abs(W*Wold')-eye(n),'fro') < convergencecriterion * n; 
        notconverged=0; end

end %of fixed-point iterations loop

disp('done \n\n');
end


function [V,E,D] = pca(X)

% do PCA on image patches
%
% INPUT variables:
% X                  matrix with image patches as columns
%
% OUTPUT variables:
% V                  whitening matrix
% E                  principal component transformation (orthogonal)
% D                  variances of the principal components


% Calculate the eigenvalues and eigenvectors of the new covariance matrix.
covarianceMatrix = X*X'/size(X,2);
[E, D] = eig(covarianceMatrix);

% Sort the eigenvalues  and recompute matrices
[dummy,order] = sort(diag(-D));
E = E(:,order);
d = diag(D); 
dsqrtinv = real(d.^(-0.5));
Dsqrtinv = diag(dsqrtinv(order));
D = diag(d(order));
V = Dsqrtinv*E';
end


function Y=removeDC(X)
% Removes DC component from image patches
% Data given as a matrix where each patch is one column vectors
% That is, the patches are vectorized.

% Subtract local mean gray-scale value from each patch in X to give output Y

Y = X-ones(size(X,1),1)*mean(X);
return;
end



function Wort=orthogonalizerows(W)
%orthogonalize rows of a matrix. 
Wort = real((W*W')^(-0.5))*W;
return;
end

function writenum(number)

%simple function to write a number (e.g. iteration count) on the screen

fprintf(' ')
fprintf(num2str(number));

%fflush produces an error in matlab but needed in octave:
try; fflush(stdout); catch; end
end

function writeline(s)

     %simple function to write something on the screen, with newline 

fprintf('\n');
fprintf(s);

%fflush produces an error in matlab but needed in octave:
try; fflush(stdout); catch; end
end
