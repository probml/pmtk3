%% Find the MLE tree from a word-document binary matrix

load newsgroups % documents, wordlist, newsgroups
X = documents'; % 16,642 documents by 100 words  (sparse logical  matrix)

disp('mlapa chowliu demo')
[G, T, W, pi, pij] = treeFitStruct(X);
CPDs = treeFitParams(G, X);
ll = treeLogprob(G, CPDs, X);

if ~isOctave()
    drawNetwork('-adjMat', G, '-nodeLabels', wordlist);
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
