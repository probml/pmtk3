%Load newsgroup names
[class_names class_ids]  = textread('train.map','%s %d'); 
num_class = length(class_names);

%Load vocabulary list
vocab  = textread('vocabulary.txt','%s'); 
D      = length(vocab);

%Load stop word list
stopwords = textread('stopwords.txt','%s','delimiter',',');
num_stop = length(stopwords);


vocabTable = java.util.Hashtable;
vocabMap   = zeros(D,1);
newVocab   = {};
c = 1;
for w=1:D
  %run the stemmer  
  w
  stem = stemmer(vocab{w});

  %Check if original or stemmed word is a stop word  
  if(length(stem)==1 | any(strcmp(stem,stopwords)) | any(strcmp(vocab{w},stopwords)))
      %Map this word to zero. Will discard.
      vocabMap(w) = 0;
  else
    %Not a stop word. Check if stem is already in vocabular list.
    if(vocabTable.containsKey(stem))
      %Stem already exists, map this word to same index as stemmed word
      %Add this word to list of words belonging to this stem
      ind = vocabTable.get(stem);
      vocabMap(w) = ind;
      newVocab{ind}{end+1}=vocab{w};
    else
      %Stem does not already exist, map this word to a new index
      %Add this word to list of words belonging to this new stem
      vocabTable.put(stem,c);
      vocabMap(w) = c;
      newVocab{c}{1}=vocab{w};    
      c=c+1;  
    end
  end
end

D = max(vocabMap);
vocabMap(vocabMap == 0) = D+1;

%Load train data and make train document-word matrix
trainWL = load('train.data');
Ntrain  = max(trainWL(:,1));
trainW  = sparse(trainWL(:,1),vocabMap(trainWL(:,2)),trainWL(:,3),Ntrain,D+1);
trainW  = trainW(:,1:D);
trainCL  = load('train.label');
trainC   = sparse(1:Ntrain,trainCL,ones(Ntrain,1));

%Load test data and make train document-word matrix
testWL  = load('test.data');
Ntest   = max(testWL(:,1));
testW   = sparse(testWL(:,1),vocabMap(testWL(:,2)),testWL(:,3),Ntest,D+1);
testW  = testW(:,1:D);
testCL  = load('test.label');
testC   = sparse(1:Ntest,testCL,ones(Ntest,1));

%Compute mutual information
W    = [trainW;testW];
C    = [trainC;testC];
N    = size(W,1);
Pw1c = (1+((W>0)'*C))/(D*num_class+sum(sum(W>0))); 
Pw0c = bsxfun(@minus,sum(Pw1c,1), Pw1c);
Pw1  = sum(Pw1c,2);
Pw0  = sum(Pw0c,2);
Pc   = sum(Pw1c,1);
MI   = sum(Pw1c.*log(Pw1c),2) - sum( Pw1c,2).*(log(Pw1)) - Pw1c*log(Pc)' ...
     + sum((Pw0c).*log(Pw0c),2) - sum(Pw0c,2).*(log(Pw0)) - Pw0c*log(Pc)';

%Sort word groups by mutual information. 
%Force all word groups in last quatile to bottom
%of list regardless of MI score.
f         = sum(W,1);
score     = MI(:).*(f(:)>quantile(f,0.25));
[foo,ord] = sort(score,'descend');

%Keep only 1000 top word groups
%Trim vocabular list and empty documents 
vocab  = newVocab(ord(1:1000));
trainW = trainW(:,ord(1:1000));
ind    = sum(trainW,2)>0;
trainW = trainW(ind,:);
trainC = trainC(ind,:);
testW  = testW(:,ord(1:1000));
ind    = sum(testW,2)>0;
testW  = testW(ind,:);
testC  = testC(ind,:);

%Display top 100 word  groups
for g=1:1000
  for w=1:length(vocab{g})
    fprintf('%s ',vocab{g}{w});
  end
  fprintf('\n');
end

save('20news.mat','trainW','testW','trainC','testC','vocab','num_class','class_names')