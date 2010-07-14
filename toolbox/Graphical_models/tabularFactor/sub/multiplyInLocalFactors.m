function factors = multiplyInLocalFactors(factors, localFactors)
%% Multiply in local factors

for i=1:numel(localFactors)
    LF = localFactors{i};
    if isempty(LF), continue; end
    v = LF.domain; assert(numel(v) == 1);
    factors{v} = tabularFactorMultiply(factors{v}, LF);
end
end