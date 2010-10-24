function [p, nerrs] = bestPermutation(source, target)
% Permute labels to minimize the number of mismatches with a target
%
%% Example
% p = bestPermutation([1 1 1 2 2 2 3 3 3], [2 2 3 1 1 1 3 3 2])
% p = 
%     2     2     2     1     1     1     3     3     3
%%

% This file is from pmtk3.googlecode.com

nlabels = nunique([rowvec(source), rowvec(target)]); 
allperms = perms(1:nlabels);
errs = zeros(1, size(allperms, 1));

for i=1:size(allperms, 1);
    perm = allperms(i, source); 
    errs(i) = sum(perm ~= target);
end

bestidx = minidx(errs);
p = allperms(bestidx, source); 
nerrs = errs(bestidx); 

end
