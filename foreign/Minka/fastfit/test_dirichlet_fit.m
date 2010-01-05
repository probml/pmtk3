a = [3 1 2];
%a = 1:10;
%a = 1:100;
a = a*10e+1;
data = dirichlet_sample(a,100*length(a));

if 0
  plot(data(:,1),data(:,2),'.')
  axis([0 1 0 1])
  return
end

run = [];
flops(0);
%[a,run.simple] = dirichlet_fit_simple(data)
flops(0);
[a,run.alternation] = dirichlet_fit(data);
flops(0);
[a,run.newton] = dirichlet_fit_newton(data);

% check it is a maximum
bar_p = mean(log(data));
err = max(abs(digamma(sum(a))-digamma(a) + bar_p));
if err < 1e-6
  disp('ok');
else
  fprintf('error: normal equations not satisfied (%g)\n', err);
end

ebest = -Inf;
for f = fieldnames(run)'
  thisrun = getfield(run,char(f));
  ebest = max([ebest max(thisrun.e)]);
end
ebest = ebest + eps;

color.simple = 'k';
color.alternation = 'bo-';
color.newton = 'go-';

figure(1),clf
for f = fieldnames(run)'
  thisrun = getfield(run,char(f));
  thisrun.err = (ebest - thisrun.e);
  semilogy(thisrun.flops,thisrun.err,getfield(color,char(f)));
  %loglog(thisrun.flops,thisrun.err,getfield(color,char(f)));
  hold on
end
hold off
xlabel('FLOPS')
ylabel('Difference from optimal value')
axis_pct;
f = fieldnames(run);
legend(f)
if 0
  legend off
  f = fieldnames(run);
  h = mobile_text(f{:});
end
set(gcf,'paperpos',[0.25 2.5 5 4])
%print -dpsc gev.ps
%save task1.mat data run

% alt does seem to be linear (same as simple)
% #iters for inv_digamma is very important
