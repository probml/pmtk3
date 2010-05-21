function w = projectLinf1BlockFast(w,p,nIndices,lambda)

W = zeros(p);
W(:) = w;
projectBlockL1(W,nIndices,lambda); % MEX file works in-place!
w = W(:);


