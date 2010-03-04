function p = polya_loo_logProb(a, data)

if any(a < 0)
  p = -Inf;
  return
end
sa = sum(a);
sdata = col_sum(data);
for i = 1:cols(data)
  p(i) = sum(data(:,i).*log(data(:,i)-1 + a));
  p(i) = p(i) - sdata(i)*log(sdata(i)-1 + sa);
end

end