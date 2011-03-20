function ndx = topAboveThresh(scores, N, thresh)
% Return indices of top N items which are above threshold
% scores(i): confidence
% N - max number to return
% thresh(i): threshold to use for scores(i); thresh can be a scalar
% 
% Examples
% topAboveThresh([1 2 3 4], 2, 1) % [4 3]
% topAboveThresh([1 2 3 4], 4, 1) % [4 3 2]
% topAboveThresh([1 2 3 4], 4, [4 4 4 4]) % [4]
 

% This file is from pmtk3.googlecode.com


D = numel(scores);
if numel(thresh)==1, thresh=thresh*ones(1,D); end
scores = colvec(scores)'; thresh = colvec(thresh)';

[~, perm] = sort(scores, 'descend');
hiconf = perm(find(scores(perm) >= thresh(perm))); %#ok
Npredict =  min(numel(hiconf), N);
ndx = hiconf(1:Npredict);

end
