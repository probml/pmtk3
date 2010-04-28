function [deltas, post, thetas] = contingencyTablePairedDiffPostMc(n00, n10, n01, n11)

S = 10000;
alphas = 0.5*ones(1,4);
ns = [n00 n10 n01 n11];
model.alpha = alphas+ns; 
thetas = dirichletSample(model, S);
diff = thetas(:,2) - thetas(:,3); % n10-n01
[post, deltas] = ksdensity(diff);
end