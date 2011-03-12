function [maxscores_prob, maxscores_raw] = extractMaxDetScore(D, names, logitCoef)
% maxscores(n,c) = max detector score for frame n, class c
% D is a LM dicitonary
N = numel(D);
C = numel(names);
maxscores_prob = zeros(N,C);
maxscores_raw = nan(N,C);
for n=1:N
    if mod(n,100)==0, fprintf('extracting max scores from image %d of %d\n', n, N); end
    objects = {D(n).annotation.object.name};
    scores = [D(n).annotation.object.confidence];
    for c=1:C
        ndx = find(strcmp(objects, names{c}));
        scores_class_c = scores(ndx);
        if ~isempty(ndx)
          maxscores_raw(n,c) =  max(scores_class_c);
          maxscores_prob(n,c) = glmval(logitCoef{c}, maxscores_raw(n,c), 'logit');
        end
    end
end

% If the detector did not fire, we set the score
% to the minimum possible (and the prob. to 0)
m = min(maxscores_raw(:));
maxscores_raw(isnan(maxscores_raw))=m;

end

