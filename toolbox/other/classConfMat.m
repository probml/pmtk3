
function M = classConfMat(ytrue, yhat)
% Make class confusion matrix
% M(truth, est) = num times truth gets labeled as est
C = max(unique(ytrue));
M = zeros(C,C);
for i=1:C
  for j=1:C
    M(i,j) = sum((ytrue==i).*(yhat==j));
  end
end



end