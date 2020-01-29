%https://www.mathworks.com/matlabcentral/fileexchange/36141-laplacian-eigenmap-diffusion-map-manifold-learning
% Author: Kye Taylor

%% create swiss roll data
N = 2^11; % number of points considered
t = rand(1,N);
t = sort(4*pi*sqrt(t))'; 
%t = sort(generateRVFromRand(2^11,@(x)1/32/pi^2*x,@(x)4*pi*sqrt(x)))';
z = 8*pi*rand(N,1); % random heights
x = (t+.1).*cos(t);
y = (t+.1).*sin(t);
data = [x,y,z]; % data of interest is in the form of a n-by-3 matrix
%% visualize the data
cmap = jet(N);
scatter3(x,y,z,20,cmap);
title('Original data');
%% Changing these values will lead to different nonlinear embeddings
knn    = ceil(0.03*N); % each patch will only look at its knn nearest neighbors in R^d
sigma2 = 100; % determines strength of connection in graph... see below
%% now let's get pairwise distance info and create graph 
m                = size(data,1);
dt               = squareform(pdist(data));
[srtdDt,srtdIdx] = sort(dt,'ascend');
dt               = srtdDt(1:knn+1,:);
nidx             = srtdIdx(1:knn+1,:);
% nz   = dt(:) > 0;
% mind = min(dt(nz));
% maxd = max(dt(nz));
% compute weights
tempW  = exp(-dt.^2/sigma2); 
% build weight matrix
i = repmat(1:m,knn+1,1);
W = sparse(i(:),double(nidx(:)),tempW(:),m,m); 
W = max(W,W'); % for undirected graph.
% The original normalized graph Laplacian, non-corrected for density
ld = diag(sum(W,2).^(-1/2));
DO = ld*W*ld;
DO = max(DO,DO');%(DO + DO')/2;
% get eigenvectors
[v,d] = eigs(DO,10,'la');
eigVecIdx = nchoosek(2:4,2);
for i = 1:size(eigVecIdx,1)
    figure,scatter(v(:,eigVecIdx(i,1)),v(:,eigVecIdx(i,2)),20,cmap)
    title('Nonlinear embedding');
    xlabel(['\phi_',num2str(eigVecIdx(i,1))]);
    ylabel(['\phi_',num2str(eigVecIdx(i,2))]);
end
figure,subplot(1,2,1)
scatter3(x,y,z,20,cmap);
title('Original data');
subplot(1,2,2)
scatter(v(:,2),v(:,4),20,cmap)
title('Nonlinear embedding')
