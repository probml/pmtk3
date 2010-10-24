function M = classConfMat(ytrue, yhat)
% Make a class confusion matrix
% M(truth, est) = num times truth gets labeled as est
% result is an array with starting index of 1, so you have to figure out
% labels separately. It will do all possible integer classes, i.e. if you
% have two classes 1 and 1000 don't use this function, however, if you have
% classes 1:9 but are missing class 7 for example, it will do the right
% thing

% This file is from pmtk3.googlecode.com

C = max(unique(ytrue));
Cmin = min(unique(ytrue));
Ccount=C-Cmin+1;
M = zeros(Ccount,Ccount);
for i=1:Ccount
  for j=1:Ccount
    M(i,j) = sum((ytrue==(Cmin+i-1)).*(yhat==(Cmin+j-1)));
  end
end



end
