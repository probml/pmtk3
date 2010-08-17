%% Fit the local CPDs of an mrf given an image / noisy image pair
%
%%


imgs = loadData('tinyImages'); 
img = double(imgs.matlabIconGray);
[M, N] = size(img); 
ns = 16; 
img = reshape(quantizePMTK(img(:), 'levels', ns), M, N);
img = canonizeLabels(img); 
nstates = max(img(:)); 
figure;
imagesc(img); colormap('bone'); title('original image');
localCPD  = condGaussCpdCreate( nstates*ones(1, nstates), ones(1, 1, nstates)); 


sigma = 0.1; 
yTrain = img./nstates + sigma*randn(M, N);
yTest  = img./nstates + sigma*randn(M, N);
figure;
imagesc(yTrain);colormap('bone'); title('noisy copy (yTrain)');
localCPD = localCPD.fitFn(localCPD, img(:), yTrain(:));

edgePot = bsxfun(@(a, b)-abs(a-b), 1:nstates, (1:nstates)'); % will be replicated
edgePot = edgePot - min(edgePot(:)) + 1;

figure; imagesc(edgePot); colormap('default'); title('tied edge potential');

if 1
    nodePot = normalize(rand(1, nstates));
else
    yGuess = floor(rescaleData(yTrain, 1, nstates));
    nodePot = cell(numel(img), 1);
    for i=1:numel(img)
        pot = zeros(1, nstates);
        guess = yGuess(i);
        pot(guess) = 1;
        nodePot{i} = tabularFactorCreate(pot, i);
    end
end
G         = mkGrid(M, N);
infEngine = 'libdai';
opts = {'TRWBP', '[updates=SEQFIX,tol=1e-9,maxiter=10000,logdomain=0,nrtrees=0]'};

mrf     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD, 'infEngine', infEngine, 'infEngArgs', opts);

nodes = mrfInferNodes(mrf, 'localev', rowvec(yTest)); 
maxMarginals = maxidx(tfMarg2Mat(nodes), [], 1);
figure; imagesc(reshape(maxMarginals, M, N)); colormap('bone'); 
title('reconstructed image'); 
placeFigures;

