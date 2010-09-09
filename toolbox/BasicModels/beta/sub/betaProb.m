function p = betaProb(t,a,b)
% p(i) =  p( t(i) | a, b)

% This file is from pmtk3.googlecode.com

p = t.^(a-1) .* (1-t).^(b-1) ./ beta(a,b);
end
