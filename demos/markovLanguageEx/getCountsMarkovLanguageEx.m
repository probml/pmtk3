function [counts1, counts2] = getCounts()

% counts1(i,l) = num times word i occurs in language l
% counts2(i,j,l) = num times word i followed by j occurs in language l
% l=1 = english, l=2 = german, l=3 = spanish, l=4 = italian

linesEng = readlines('cnn.eng');
linesGer = readlines('cnn.ger');
linesSpa = readlines('cnn.spa');
linesIta = readlines('cnn.ita');

k = 1;
c1eng = totalcount(linesEng, k);
c1ger = totalcount(linesGer, k);
c1spa = totalcount(linesSpa, k);
c1ita = totalcount(linesIta, k);
counts1 = [c1eng, c1ger, c1spa, c1ita];

k = 2;
c2eng = totalcount(linesEng, k);
c2ger = totalcount(linesGer, k);
c2spa = totalcount(linesSpa, k);
c2ita = totalcount(linesIta, k);

counts2 = cat(3, c2eng, c2ger, c2spa, c2ita);

%%%%%%%%%%

function c = totalcount(lines,k)
c=0;
for i=1:length(lines)
  c=c+count(text2stream(lines{i}),k);
end;

%%%%%%%%

function c = count(data,k)
% If k=1: c(i) = sum_{t=1}^T I(data(t)==i)
% If k=2: c(i,j) = sum_{t=1}^T{T-1} I(data(t)==i, data(t+1)=j)

nstates = 27;
if k==1
  c = compute_counts(data, nstates);
elseif k==2
  c = compute_counts([data(1:end-1); data(2:end)], [nstates nstates]);
else
  error('k is too large')
end
  
