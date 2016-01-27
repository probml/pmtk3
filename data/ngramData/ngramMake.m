% Compute  unigrams and bigrams of Darwin's "On the origin of
% species". Written by Matthew Dunham

close all;
verbose = 1;

fid = fopen('darwin.txt'); 
if(verbose),display('reading file...'),end;
data = fread(fid); 
if(verbose),display('done'),end;
fclose(fid); 

lcase = abs('a'):abs('z');
ucase = abs('A'):abs('Z');
caseDiff = abs('a') - abs('A');

if(verbose),display('converting all letters to lower case...'),end;
caps = ismember(data,ucase);
data(caps) = data(caps)+caseDiff;
if(verbose),display('done'),end;

if(verbose),display('removing punctuation...'),end;
validSet = [abs(' ') lcase];
data = data(ismember(data,validSet));
if(verbose)
  display('done');
  display('computing unigrams and bigrams...');
end
ugrams = zeros(27,1);
bigrams = zeros(27,27);
shiftVal = abs('a') - 2;           % 'a' will be at index 2
shift = @(x) max(1,x - shiftVal);  % space will be at index 1
for i=1:length(data)-1
  fromIDX = shift(data(i));
  ugrams(fromIDX) = ugrams(fromIDX) + 1;
  toIDX = shift(data(i+1));
  bigrams(fromIDX,toIDX) = bigrams(fromIDX,toIDX) + 1;
end
if(verbose)
  display('done');
  display('removing extra whitespace...');
  display('done');
end
ugrams(1) = ugrams(1)-bigrams(1,1);
bigrams(1,1)=0; %space to space
last = shift(data(length(data)));
ugrams(last) = ugrams(last) + 1;
ugramsNorm = mkStochastic(ugrams);
bigramsNorm = mkStochastic(bigrams);
clear ans caps fid loadExisting i last fromIDX toIDX;
save ngramData;

