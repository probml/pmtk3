%% Find the MLE tree from a word-document binary matrix

% This file is from pmtk3.googlecode.com


loadData('20news_w100'); % documents, wordlist, newsgroups
%X is 16,642 documents by 100 words  (sparse logical  matrix)
X = documents';
disp('mlapa chowliu demo')

%setSeed(0);
%X = randn(100,5)>0;
model = treegmFit(X);
%dgm = treeToDgm(model);

ll = treegmLogprob(model, X);


if ~isOctave()
    drawNetwork('-adjMat', model.adjmat, '-nodeLabels', wordlist);
end
% Plot loglikelihood of training cases
figure;hist(ll,100); title('log-likelihood of training cases using ChowLiu tree')

% Find words in datacases with best  and worst  likelihoods
[junk, ndx] = sort(ll, 'descend');
chosen = [ndx(1:5)' ndx(end-2:end-1)']; % sentence indexes
for i=1:length(chosen)
  j = chosen(i);
  fprintf('words in sentence %d with loglik %5.3f\n', j, ll(j));
  wordlist(X(j,:))
end

% loglik decreases as number of density of bit vector increases
doclen = sum(X, 2);
figure;
plot(doclen(ndx), 'r-');
hold on
plot(ll(ndx), 'b:')
legend('doclen', 'loglik')
