function s = dirichlet_initial_s(m, bar_p)

K = length(m);
m = m/sum(m);
s = (K-1)/2/(-sum(m.*bar_p)+sum(m.*log(m)));

end