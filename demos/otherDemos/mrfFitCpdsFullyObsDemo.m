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
imagesc(img); colormap('bone'); title('original image');
localCPD  = condGaussCpdCreate( nstates*ones(1, nstates), ones(1, 1, nstates)); 


sigma = 0.1; 
yTrain = img./nstates + sigma*randn(M, N);
yTest  = img./nstates + sigma*randn(M, N);
figure;
imagesc(yTrain);colormap('bone'); title('noisy copy');
localCPD = localCPD.fitFn(localCPD, img(:), yTrain(:));

edgePot = bsxfun(@(a, b)-abs(a-b), 1:nstates, (1:nstates)') + nstates/2; % will be replicated
imagesc(edgePot); colormap('default'); title('tied edge potential');
nodePot   = repmat(1./nstates, 1, nstates); 

G         = mkGrid(M, N);
infEngine = 'libdai';
opts = {'TRWBP', '[updates=SEQFIX,tol=1e-6,maxiter=1000,logdomain=0,nrtrees=0]'};

mrf     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD, 'infEngine', infEngine, 'infEngArgs', opts);




nodes = mrfInferNodes(mrf, 'localev', rowvec(yTest)); 
maxMarginals = max(tfMarg2Mat(nodes), [], 1);
imagesc(reshape(maxMarginals, M, N)); colormap('bone'); 




if 0

setSeed(0); 
assert(isLibdaiInstalled); 
infEngine = 'bp';
imgs = loadData('tinyImages'); 
img = double(imgs.matlabIconGray);
[M, N] = size(img); 
nstates = 16; 
img = reshape(quantizePMTK(img(:), 'levels', nstates), M, N);
imagesc(img); colormap('bone'); title('original image');


sigma = 1; 
y = img./nstates + sigma*randn(M, N);
figure;
imagesc(y);colormap('bone'); title('noisy copy');


localCPD  = condGaussCpdCreate( nstates*rand(1, nstates), ones(1, 1, nstates)); % initial guess
edgePot = bsxfun(@(a, b)-abs(a-b), 1:nstates, (1:nstates)') + nstates/2;
imagesc(edgePot); colormap('default');
nodePot   = repmat(1./nstates, 1, nstates); 
G         = mkGrid(M, N);
model     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD, 'infEngine', infEngine);
localev = insertSingleton(rowvec(y), 1); % single training case, size must be 1-by-d-by-nnodes
model = mrfFitEm(model, rowvec(img), 'localev', localev, 'maxIter', 2); 

model.infEngine = 'bp';  
model.infEngArgs = {'maxIter', 10, 'verbose', true}; 
nodes = mrfInferNodes(model, 'localev', rowvec(y)); 

maxMarginals = max(tfMarg2Mat(nodes), [], 1);
imagesc(reshape(maxMarginals, M, N)); colormap('bone'); 

end