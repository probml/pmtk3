x = [-Inf; -Inf];
if(logsumexp(x) ~= -Inf)
  error('logsumexp([-Inf; -Inf]) should be -Inf');
end
%logsumexpv(x)

x = rand(1000,1);
tic; for iter = 1:1000 logsumexp(x); end; toc
%tic; for iter = 1:1000 logsumexpv(x); end; toc
