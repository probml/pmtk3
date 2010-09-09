function blocks = mrf2ImgMkTwoBlocks(nRows, nCols)
%% Make Blocks - comb structure (2 interlocking trees)

% This file is from pmtk3.googlecode.com

nNodes = nRows*nCols;
nodeNums = reshape(1:nNodes,nRows,nCols);
blocks1 = zeros(nNodes/2,1);
blocks2 = zeros(nNodes/2,1);
b1Ind = 0;
b2Ind = 0;
for j = 1:nCols
    if mod(j,2) == 1
        blocks1(b1Ind+1:b1Ind+nCols-1) = nodeNums(1:nCols-1,j);
        b1Ind = b1Ind+nCols-1;
        
        blocks2(b2Ind+1) = nodeNums(nRows,j);
        b2Ind = b2Ind+1;
    else
        blocks1(b1Ind+1) = nodeNums(1,j);
        b1Ind = b1Ind+1;
        
        blocks2(b2Ind+1:b2Ind+nCols-1) = nodeNums(2:nCols,j);
        b2Ind = b2Ind+nCols-1;
    end
end
blocks = {blocks1;blocks2};

if 0
mask  = zeros(nNodes,1);
mask(blocks1) = 1;
mask(blocks2) = 2;
figure; imagesc(reshape(mask, nRows, nCols)); colormap gray
title('block structure')
printPmtkFigure('mrfImgBlockStructure')
end

end
