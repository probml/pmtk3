function plotPatches( A, cols)
% display receptive field(s) or basis vector(s) for image patches
%
% A(:,i) is i'th patch, assumed to be square
% cols      number of columns (x-dimension of grid)

% This file is from pmtk3.googlecode.com


if nargin < 2
  [nr nc] = nsubplots(size(A,2));
  cols = nc;
end

%PMTKauthor Aaop Hyvarinen

%set colormap
colormap(gray(256));

%normalize each patch
A=A./(ones(size(A,1),1)*max(abs(A)));

% This is the side of the window
dim = sqrt(size(A,1));

% Helpful quantities
dimp = dim+1;
rows = floor(size(A,2)/cols);  %take floor just in case cols is badly specified

% Initialization of the image
I = ones(dim*rows+rows-1,dim*cols+cols-1);

%Transfer features to this image matrix
for i=0:rows-1
  for j=0:cols-1
    % This sets the patch
    I(i*dimp+1:i*dimp+dim,j*dimp+1:j*dimp+dim) = ...
         reshape(A(:,i*cols+j+1),[dim dim]);
  end
end

%Save of plot results
imagesc(I); 
axis equal
axis off
%print('-dps',[figurepath,filename,'.eps'])

end
