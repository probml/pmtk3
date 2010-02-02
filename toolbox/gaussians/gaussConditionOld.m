function [muAgivenB, SigmaAgivenB] = gaussCondition(mu, Sigma, a, x)
% p(A|x) where x(b) is instantiated and x(a) is don't care

D = length(mu);
b = setdiff(1:D, a);  % visVars
if isempty(a)
  muAgivenB = []; SigmaAgivenB  = [];
else
  SAA = Sigma(a,a); SAB = Sigma(a,b); SBB = Sigma(b,b);
  SBBinv = inv(SBB);
  muAgivenB = mu(a) + SAB*SBBinv*(x(b)-mu(b));
  SigmaAgivenB = SAA - SAB*SBBinv*SAB';
end

end




