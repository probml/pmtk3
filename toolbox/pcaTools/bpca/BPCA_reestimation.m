function [nrmse, M2, rmse] =BPCA_reestimation(M, rate)

disp('reestimation new version');

if nargin ~= 2
  rate = 0.01
end

xorg = M.yest;
[N,D] = size(xorg);
x999 = xorg;
nm = N*D*rate;
n = 0;

rand('state',0);
while(n<nm)
  i = ceil(N*rand);
  j = ceil(D*rand);
  if x999(i,j)~=999
    if isempty(M.missidx{i})
      x999(i,j)=999;
      n = n+1;
    elseif isempty( find(M.missidx{i}==j) )
      x999(i,j)=999;
      n = n+1;
    end
  end
end

[xfilled,M2] = BPCAfill(x999, M.q);
[nrmse, rmse] = missingNRMSE(x999, xfilled, xorg);

end