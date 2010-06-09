function w = groupL2Proj(w,tau,groups)

ind = groups~=0;

norms = sqrt(accumarray(groups(ind),w(ind).^2));

if sum(norms) > tau
    projectedNorms = projectRandom2(norms,tau);
    norms(norms==0) = 1;
    for i = 1:max(groups)
       w(groups==i) = w(groups==i)*(projectedNorms(i)/norms(i)); 
    end
end
