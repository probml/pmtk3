a = [3 1 2];
data = polya_sample(a, rand(1,100)*10);

if 1
  % plot the objective over s
  inc = 0.1;
  ss = inc:inc:10;
  for i = 1:length(ss)
    a = full(m*ss(i));
    e(i) = sum(polya_logProb(a, data));
  end
  %figure
  %plot(ss, e)
  [dummy,i] = max(e);
  fprintf('max is at %g\n', ss(i));
end

%figure(1)
a = polya_fit_s(data,a)
s = sum(a)
