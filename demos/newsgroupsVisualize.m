%% Visualize word-document binary matrix
%
%%

% This file is from pmtk3.googlecode.com

loadData('20news_w100');
 % documents, wordlist, newsgroups, groupnames
X = documents'; % 16,642 documents by 100 words  (sparse logical  matrix)
y = uint8(newsgroups); % class label, 1..4
classlabels = groupnames;

%% Visualize raw data
% First sort so that documents with the most words present come first.
% Pick the first 1000.
nwords = full(sum(X,2));
[junk, ndx] = sort(nwords,  'descend');
ndx = ndx(1:1000);
XX = X(ndx,:);
yy = y(ndx);

% Now sort by label
[yy, ndx] = sort(yy);
XX = XX(ndx,:);
figure; imagesc(XX); colormap(gray);
% Draw a horizontal line to demarcate each class
d = size(X,2);
for c=1:length(unique(yy))-1
  ndx = find(yy==c);
  hh = ndx(end);
  line([1 d], [hh hh], 'linewidth', 3, 'color', 'r');
end
xlabel('words'); ylabel('documents')
printPmtkFigure('newsgroupsSpyWithLabels'); 

%% Print a sentence (bag of words) chosen at random for each class
setSeed(1);
for c=1:length(unique(yy))
  fprintf('words in sentences from class %s\n\n', classlabels{c});
  for t=1:3
    % pick a random document from this class and print its words
    ndx = find(yy==c);
    n = length(ndx);
    k = randi(n, 1, 1); %floor(rand(1,1)*n)+1;
    fprintf('%s ', wordlist{XX(ndx(k),:)}); fprintf('\n');
    assert(yy(ndx(k))==c) % book-keeping sanity check!
  end
  fprintf('\n\n');
end
 
