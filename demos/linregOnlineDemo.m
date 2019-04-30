function main()
standardize = false; %true;

[xtrain, ytrain] = polyDataMake('sampling','thibaux');
if standardize
  [xtrain] = standardizeCols(xtrain);
end

N = length(xtrain);
wBatch = [ones(N,1) xtrain] \ ytrain;

ss = [];
for i=1:N
  [w(:,i),ss] = linregUpdateSS(ss, xtrain(i), ytrain(i), xtrain, ytrain);
end
figure; hold on
h=plot(w(1,:), 'ko', 'linewidth', 2);
plot(w(2,:), 'r*', 'linewidth', 2);
plot(1:N, wBatch(1)*ones(1,N), 'k-', 'linewidth', 2);
plot(1:N, wBatch(2)*ones(1,N), 'r:', 'linewidth', 2);
h=legend('w0', 'w1', 'w0 batch', 'w1 batch');
axis_pct
title('online linear regression')
ylabel('weights')
xlabel('time')
if standardize
  printPmtkFigure('linregOnlineDemoStnd')
  set(h, 'location', 'southeast')
else
  printPmtkFigure('linregOnlineDemo')
  set(h, 'location', 'east')
end

end



function [w,ss] = linregUpdateSS(ss, xnew, ynew, xAll, yAll)

if isempty(ss)
  ss.xbar = xnew; ss.ybar = ynew;
  ss.Cxx = 0; ss.Cxy = 0;
  ss.Cxx2 = 0; ss.Cxy2 = 0;
  ss.Cxx3 = 0; ss.Cxy3 = 0;
  ss.n = 1;
else
  ssOld = ss;
  n = ss.n; n1 = n+1;
  ss.n = ss.n + 1;
  ss.xbar = ssOld.xbar + (1/n1)*(xnew-ssOld.xbar);
  ss.ybar = ssOld.ybar + (1/n1)*(ynew-ssOld.ybar);
  ss.Cxy = (1/n1)*( xnew*ynew + n*ssOld.Cxy ...
    + n*ssOld.xbar*ssOld.ybar - n1*ss.xbar*ss.ybar);
  ss.Cxx = (1/n1)*( xnew^2 + n*ssOld.Cxx ...
    + n*ssOld.xbar*ssOld.xbar - n1*ss.xbar*ss.xbar);
  
  % debugging
  if 1
    ndx = 1:ss.n;
    assert(approxeq(ss.xbar, mean(xAll(ndx))))
    assert(approxeq(ss.ybar, mean(yAll(ndx))))
    assert(approxeq(ss.Cxy, mean((xAll(ndx)-ss.xbar) .* (yAll(ndx)-ss.ybar))))
    assert(approxeq(ss.Cxx, mean((xAll(ndx)-ss.xbar).^2)))
  end
  
%{
  ss.Cxx2 = (n/(n+1))*(ssOld.Cxx + (1/(n+1))*(xnew-ssOld.xbar)^2);
  assert(approxeq(ss.Cxx, ss.Cxx2))
  ss.Cxy2 = (n/(n+1))*(ssOld.Cxy + (1/(n+1))*(xnew-ssOld.xbar)*(ynew-ssOld.ybar));
  assert(approxeq(ss.Cxy, ss.Cxy2))
  
  % Yi Huang
  %ss.Cxx3 = ssOld.Cxx3 + (n/(n+1))*(xnew-ssOld.xbar)^2;
  %assert(approxeq(ss.Cxx, ss.Cxx3))
  %%ss.Cxy3 = ssOld.Cxy3 + (n/(n+1))*(xnew-ssOld.xbar)*(ynew-ssOld.ybar);
  assert(approxeq(ss.Cxy, ss.Cxy3))
  %}
end


w1 = ss.Cxy/ss.Cxx;
w0 = ss.ybar - w1*ss.xbar;
w = [w0; w1];

% debugging
if 1
  ndx = 1:ss.n;
  ww = [ones(ss.n,1) xAll(ndx)] \ yAll(ndx);
  assert(approxeq(ww, w))
end
end

