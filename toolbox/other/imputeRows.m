function Ximpute = imputeRows(Xmiss)
% Perform row imputation

%PMTKauthor Hannes Bretschneider

[N D] = size(Xmiss);
Ximpute = Xmiss;
for i=1:N
    row = Xmiss(i,:);
    missVal = isnan(row);
    if any(missVal), Ximpute(i,missVal) = mean(row(~missVal)); end;
end
end
