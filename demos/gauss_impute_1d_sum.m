% Infer 1d function from observing its average value over various intervals
function gauss_impute_1d_sum()

Bs = [1, 5, 10, 20]; % bucket width
sigmas = [1e-3, 1e-1];
for i=1:length(Bs)
    for j=1:length(sigmas)
       B = Bs(i);
        sigma = sigmas(j);
        run_demo(B,sigma)
    end
end

function run_demo(B, sigma)
setSeed(1);
D = 100;
xs = 1:D;


N = D/B;
A = zeros(N, D);
j = 1;
for bucket=1:N
    A(bucket, j:j+B-1) = 1/B;
    j = j+B;
end

z = sin( (xs/D) * 4*pi);
y_noisefree = A*z(:);
y = y_noisefree + sigma*randn(N,1);

y_replicated = zeros(1,D);
y_noisefree_replicated = zeros(1,D);
j = 1;
centers = zeros(1,N);
%centers = (B/2) + (0:D-1)*B;
for bucket=1:N
    start = 1+(bucket-1)*B;
    stop = start+B-1;
    centers(bucket) = start + (stop-start)/2;
    y_replicated(start:stop) = y(j);
    y_noisefree_replicated(start:stop) = y_noisefree(j);
    j = j + 1;
end
 
 
% Make a (D-2) * D tridiagonal matrix
L = spdiags(ones(D-2,1) * [-1 2 -1], [0 1 2], D-2, D);
lambda = 20;
L = L * lambda;

precMat = L'*L + 1e-3;
%priorDist.mu = zeros(D, 1);
%priorDist.Sigma = inv(precMat);
obsDist.Sigma = sigma*eye(N,N);
%postDist = gaussSoftCondition(priorDist, obsDist, A, y);
obsPrec = inv(obsDist.Sigma);
postDist.Sigma = inv(precMat + A'*obsPrec*A);
postDist.mu = postDist.Sigma*A'*obsPrec*y;

nr = 1; nc = 2;
figure; 
%{
subplot(nr, nc, 1);
plot(xs, z, 'r-');
ylim([-1.5 1.5])
title('truth')
%}

subplot(nr, nc, 1); 
hold on
%plot(xs, y_replicated, 'b-', 'linewidth', 2);
plot(centers, y, 'bo');
plot(xs, y_noisefree_replicated, 'k-', 'linewidth', 2);
legend('observed', 'noisefree');
title(sprintf('B=%d, sigma=%5.3f', B, sigma));

subplot(nr, nc, 2);
hold on
mu = postDist.mu;
S2 = diag(postDist.Sigma);
f = [mu+2*sqrt(S2); flipdim(mu-2*sqrt(S2),1)];
fill([xs'; flipdim(xs',1)], f, [7 7 7]/8, 'EdgeColor', [7 7 7]/8);
hmu = plot(xs, mu, 'k-', 'linewidth', 2);
hz = plot(xs, z, 'r-', 'linewidth', 2);
ylim([-1.5 1.5])
legend([hmu, hz], 'posterior', 'truth')
title(sprintf('lambda=%5.3f', lambda))


fname = sprintf('gauss_impute_1d_sum_B%d_sigma%d', B, int32(sigma*1000));
print(fname)
printPmtkFigure(fname);

end % run demo

end % script
