%% Visualize word-document binary matrix

load newsgroups % documents, wordlist, newsgroups, groupnames
X = documents'; % 16,642 documents by 100 words  (sparse logical  matrix)


% Visualize raw data
% First sort so that documents with the most words present come first.
% Pick the first 1000.
nwords = full(sum(X,2));
[junk, ndx] = sort(nwords,  'descend');
ndx = ndx(1:1000);
XX = X(ndx,:);
y = newsgroups;
yy = y(ndx);
% Now sort by label
[yy, ndx] = sort(yy);
XX = XX(ndx,:);
figure; imagesc(XX); colormap(gray);
% Draw a horizontal line to dermacate each class
d = size(X,2);
for c=1:length(unique(yy))-1
  ndx = find(yy==c);
  hh = ndx(end);
  line([1 d], [hh hh], 'linewidth', 3, 'color', 'r');
end


% Print a sentence (bag of words) chosen at random for each class
setSeed(1);
for c=1:length(unique(yy))
  fprintf('words in sentences from class %s\n\n', groupnames{c});
  for t=1:3
    ndx = find(yy==c);
    n = length(ndx);
    k = floor(rand(1,1)*n)+1;
    fprintf('%s ', wordlist{XX(ndx(k),:)}); fprintf('\n');
    assert(yy(ndx(k))==c) % book-keeping sanity check!
  end
  fprintf('\n\n');
end
 