function smallT = margTable(bigT, bigdom, bigsz, onto, maximize)
% Marginalize a table

% This file is from pmtk3.googlecode.com


if nargin < 5, maximize = 0; end

smallT = reshapePMTK(bigT, bigsz);        % make sure it is a multi-dim array
sum_over = setdiffPMTK(bigdom, onto);
if isempty(sum_over)
    smallT = bigT; return;
end
ndx = lookupIndices(sum_over, bigdom);
if maximize
    for i=1:length(ndx)
        smallT = max(smallT, [], ndx(i));
    end
else
    for i=1:length(ndx)
        smallT = sum(smallT, ndx(i));
    end
end
ns = zeros(1, max(bigdom));
ns(bigdom) = bigsz;
smallT = squeeze(smallT);               % remove all dimensions of size 1
smallT = reshapePMTK(smallT, ns(onto)); % put back relevant dims of size 1
end
