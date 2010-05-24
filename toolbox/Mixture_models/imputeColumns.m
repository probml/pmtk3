function Ximpute = imputeColumns(Xmiss)
% Column imputation

%PMTKauthor Hannes Bretschneider

[N D] = size(Xmiss);
Ximpute = Xmiss;
for j=1:D
    col = Xmiss(:,j);
    missVal = isnan(col);
    if any(missVal), Ximpute(missVal,j) = mean(col(~missVal)); end;
end
end