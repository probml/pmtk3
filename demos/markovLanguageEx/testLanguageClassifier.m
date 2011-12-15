function succp = testC(streams,labels,func,varargin)
% Test classifier performance as a function of length (averaged over streams)
%
% Input:
% streams{i} is the i'th text stream (eg output of readlines)
% labels(i) is the true label for stream i
% func is a function that will be called for each prefix of streams
% varargin - optional arguments passed to func (eg counts)
%
% Output:
% succp(j) = average success probability assuming we use the first j entries of each stream

succount = zeros(2);
for i=1:size(streams)
  s = streams{i};
  if ischar(s), s=text2stream(s); end;
  if length(succount)<length(s)
    succount(:,length(s))=0;
  end;
  for j=1:length(s)
    correct = 1+(feval(func,s(1:j),varargin{:})==labels(i));
    succount(correct,j) = succount(correct,j)+1;
  end;
end;
succp = succount(2,:)./sum(succount);
  
