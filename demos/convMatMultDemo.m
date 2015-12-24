function convMatMultDemo()
% convolution as matrix multiply

%% Demo of im2col
X = reshape(1:20, [4 5]);
phi = im2col(X, [3 3], 'sliding');
disp('X')
printMatrixToLatex(X)
disp('Xcol')
printMatrixToLatex(phi)


%% Single 2d filter applied to 2d image
setSeed(0);
X = randn(8,10);
F = randn(3,3);
Y = myxcorr2(X, F); % cross correlation

f = F(:);
phi = im2col(X, [3, 3], 'sliding')'; % im2row
vy = phi*f;
YY = reshape(vy, size(Y));
approxeq(Y, YY)

%% Bank of  2d filters applied to 3d tensor 
%{
setSeed(0);
X = randn(8,10,2);
F = randn(3,3,2,4);
Y = myconv2(X,F); % size 6x8x4
disp(size(Y))

f = F(:);
phi = im2row(X, [3, 3]);
vy = phi*f;
YY = reshape(vy, [H W]);

approxeq(Y, YY)
%}

keyboard
end

function Y = myconv2(X, K)
[HK, WK, DK, DY] = size(K); %#ok
tmp = conv2(X, K, 'valid'); % compute size of output feature map
[HY, WY] = size(tmp);
Y = zeros(HY, WY, DY);
for dy=1:DY
    for dk=1:DK
        Y(:,:,dy) = Y(:,:,dy) + myxcorr2(X(:,:,dk), K(:,:,dk,dy));
    end
end
end

function Y = myxcorr2(X, K)
Y = conv2(X, rot90(rot90(K)), 'valid');
end

function phi = im2row(X, windowSize)
% not finished
[H, W, D] = size(X);
tmp = im2col(X(:,:,1), windowSize, 'sliding')';
patchSize = prod(windowSize);
assert(patchSize == size(tmp,1));
npatches = size(tmp, 2);
phi = zeros(patchSize*D, size(tmp,2));
end

function printMatrixToLatex(phi)
for i=1:size(phi,1)
    for j=1:size(phi, 2)
        fprintf('%d & ', phi(i,j));
    end
    fprintf('\\\\\n');
end
end

