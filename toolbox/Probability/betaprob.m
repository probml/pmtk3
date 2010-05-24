function p = betaprob(t,a,b)
% p(i) =  p( t(i) | a, b)
p = t.^(a-1) .* (1-t).^(b-1) ./ beta(a,b);
end
