


% test.labels(n,d) = 1 or 2
% test.labelsMasked(n,d) = 1 or 2 or nan
% pred(n, d, v) = prob(node d = state v | case n)
% truth3d(n, d, v) = 1 iff node d is in state v in case n

[Ntest Nnodes] = size(test.labels);
missingMask = isnan(test.labelsMasked);

% Kevin's way
% sum_n sum_d log pred(n, d, y(n,d))
logprob = reshape(log2(pred(find(truth3d)) + eps), [Ntest Nnodes]);
crossEntropy = -sum(logprob(:))
crossEntropy = -sum(logprob(missingMask))
missingMask3d = repmat(missingMask, [1 1 nClass(1)]);
%crossEntropy = -sum(truth3d log2(pred(find(truth3d)) + eps), [Ntest Nnodes]);

% Emt's way
% sum_n sum_d sum_k y(n,d,k) .* log pred(n,d,k)
nClass = 2*ones(1, Nnodes); 
yd = test.labelsMasked';
ydT = test.labels';
ydT_oneOfM = encodeDataOneOfM(ydT, nClass, 'M');
yd_oneOfM = encodeDataOneOfM(yd, nClass, 'M');
N = size(yd_oneOfM,2);
miss = isnan(yd_oneOfM);
% yhatD is DK * N
pred2 = permute(pred, [3 2 1]); % K D N
pred3 = reshape(pred2, [sum(nClass) Ntest]);
yhatD = pred3+eps;
entrpyD = -sum(ydT_oneOfM(miss).*log2(yhatD(miss)))

