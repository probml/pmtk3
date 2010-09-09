%% Visualize word-document binary matrix
%
%%

% This file is from pmtk3.googlecode.com

loadData('XwindowsDocData');% xtrain is 900x600 doc by words  (sparse logical  matrix)

%% Visualize raw data
X = xtrain;
y = ytrain;

% Now sort by label
[y, ndx] = sort(y);
X = X(ndx,:);
figure; imagesc(X); colormap(gray);
% Draw a horizontal line to demarcate each class
d = size(X,2);
for c=1:length(unique(y))-1
  ndx = find(y==c);
  hh = ndx(end);
  line([1 d], [hh hh], 'linewidth', 3, 'color', 'r');
end
xlabel('words'); ylabel('documents')
printPmtkFigure('xwindowsDocSpyWithLabels'); 

