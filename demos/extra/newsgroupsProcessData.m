%% Process the 20 newsgroup data from
% http://www.cs.toronto.edu/~roweis/data.html

load newsgroups % documents, wordlist, newsgroups
X = documents'; % 16,642 documents by 100 words  (sparse logical  matrix)
y = newsgroups; % class label, 1..4

%{
% Let us filter out all documents with less than 5 words
nwords = sum(X,2);
ndx = find(nwords<5);
X(ndx,:) = []; % 10,992 documents by 100 words
%}

% Let us filter out duplicate documents
[X,ndx] = unique(X, 'rows'); % 10,267 x 100
y = y(ndx);

save('newsgroupsUnique.mat', 'X', 'wordlist', 'y')