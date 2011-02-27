%% Image denoising using an mrf and exact inference

% This file is from pmtk3.googlecode.com


%% Generate Data
%input matrix consisting of letter A. The body of letter A is made of 1's
%while the background is made of -1's.
% We use a small 8x8 image so we can use exact inference
setSeed(0);

if imagesToolboxInstalled
    sigma  = 1; % noise level
    data   = loadData('letterA');
    img    = imresize(data.A, [8, 8], 'cubic');
    [M, N] = size(img);
    img    = double(img);
    m      = mean(img(:));
    imgOrig = img;
    img   = +1*(img>m) + -1*(img<m); % -1 or +1
else 
    img =[
        1     1    -1     1     1    -1     1     1
        1     1    -1     1     1    -1     1     1
        -1    -1    -1     1     1    -1    -1    -1
        1     1     1    -1    -1     1     1     1
        1     1     1    -1    -1     1     1     1
        -1    -1    -1     1     1    -1    -1    -1
        1     1    -1     1     1    -1     1     1
        1     1    -1     1     1    -1     1     1
        ];
end
figure;
imagesc(img); colormap('gray'); title('original image');
sigma = 0.5;
[M, N] = size(img);
y = img + sigma*randn(M, N);
figure;
imagesc(y);colormap('gray'); title('noisy copy');


%% Create the model
sigma2    = sigma.^2; % we assume we know this
localCPD  = condGaussCpdCreate( [-1 +1], [sigma2, sigma2]);
J         = 0.5; % coupling strength
edgePot   = exp([J -J; -J J]);
nodePot   = [0.5 0.5];
G         = mkGrid(M, N);
model     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD);

map = mrfMap(model, 'localev', rowvec(y)); 


figure;
imagesc(reshape(map, M, N));colormap('gray'); title('MAP estimate');

nodeBels  = mrfInferNodes(model, 'localev', rowvec(y));
maxMarginals = maxidx(tfMarg2Mat(nodeBels), [], 1) - 1;
figure;
imagesc(reshape(maxMarginals, M, N));
colormap('gray'); title('marginal MAP estimate');
