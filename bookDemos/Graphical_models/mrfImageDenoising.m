%% Image denoising using an mrf and exact

%% Generate Data
%input matrix consisting of letter A. The body of letter A is made of 1's
%while the background is made of -1's.
setSeed(0);

if imagesToolboxInstalled
    sigma  = 1; % noise level
    data   = loadData('lettera');
    img    = imresize(data.A, [8, 8], 'cubic');
    [M, N] = size(img);
    img    = double(img);
    m      = mean(img(:));
    img2   = +1*(img>m) + -1*(img<m); % -1 or +1
    figure; 
    imagesc(img2); 
    title('original image'); 
    y      = img2 + sigma*randn(size(img2)); %y = noisy signal
    figure; imagesc(y); title('noisy copy'); 
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
    figure;
    imagesc(img);
    title('original image');
    sigma = 0.5;
    [M, N] = size(img);
    y = img + sigma*randn(M, N);
    figure;
    imagesc(y);
    title('noisy copy');
    
end
%% Create the model
sigma2    = sigma.^2; % we assume we know this
localCPD  = condGaussCpdCreate( [-1 +1], [sigma2, sigma2]);
J         = 0.5; % coupling strength
edgePot   = exp([J -J; -J J]);
nodePot   = [0.5 0.5];
G         = mkGrid(M, N);
model     = mrfCreate(G, 'nodePots', nodePot, 'edgePots', edgePot,...
    'localCPDs', localCPD);

map = mrfMap(model, 'localev', y(:)); 

%nodeBels  = mrfInferNodes(model, 'localev', y(:));
%maxMarginals = maxidx(tfMarg2Mat(nodeBels), [], 1) - 1;
figure;
%imagesc(reshape(maxMarginals, M, N));
imagesc(reshape(map, M, N));
title('reconstructed image');
