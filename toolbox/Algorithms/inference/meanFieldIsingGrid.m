function mu = meanFieldIsingGrid(J, CPDs, logprobFn, img, varargin)
% img should be an m*n  matrix
% CPDs{1}=p(y|s=-1), CPDs{2}=p(y|s=1)
% mu(i,j) = E(S(i,j)|y) where S(i,j) in {-1,1}
% logprobFn is a handle to a function that will be called with
% logprobFn(CPDS{i}, img(:))
%%

% This file is from pmtk3.googlecode.com

[maxIter, progressFn,  inplaceUpdates, rate] = process_options(...
    varargin, 'maxiter', 100, 'progressFn', [], ...
    'inplaceUpdates', true, 'updateRate', 1);

[M,N] = size(img);
offState = 1; onState = 2;
logodds = logprobFn(CPDs{onState}, img(:)) - logprobFn(CPDs{offState}, img(:));
logodds = reshape(logodds, M, N);

% init
p1 = sigmoid(logodds);
mu = 2*p1-1;
mu = reshape(mu, M, N);

for iter = 1:maxIter
    muNew = mu;
    for ix=1:N
        for iy=1:M
            pos = iy + M*(ix-1);
            neighborhood = pos + [-1,1,-M,M];
            neighborhood(([iy==1,iy==M,ix==1,ix==N])) = [];
            Sbar = J*sum(mu(neighborhood));
            if ~inplaceUpdates
                muNew(pos) = (1-rate)*muNew(pos) + rate*tanh(Sbar + 0.5*logodds(pos));
            else
                mu(pos) = (1-rate)*mu(pos) + rate*tanh(Sbar + 0.5*logodds(pos));
            end
        end
    end
    if ~inplaceUpdates, mu = muNew; end
    if ~isempty(progressFn), feval(progressFn, mu, iter); end
end

end
