% Parse the file 04cars.dat from
% http://www.amstat.org/publications/jse/datasets/04cars.txt

if 0
fid = fopen('04cars.dat');
%dat = textscan(fid, '%45c%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d%d');
while 1
  tline = fgetl(fid);
  if ~ischar(tline), break, end
  disp(tline)
end
fclose(fid);
end

%Cosma Shalizi has already parsed the data and removed rows with missing values
% http://www.stat.cmu.edu/~cshalizi/350/lectures/10/cars-fixed04.dat

data = importdata('04cars-fixed.csv');
X  = data.data; % 387 rows, 18 features, 1-7 are binary, rest are integer
names = data.textdata(2:end);
types = [repmat('b', 1, 7) repmat('c', 1, 11)];
header = data.textdata{1};
ndx = strfind(header, ',');
ndx(end+1) = length(header)+1;
start = 1;
for i=1:length(ndx)
  stop = ndx(i)-1;
  varlabels{i} = header(start:stop);
  start = ndx(i) + 1;
end

save('04cars.mat', 'X', 'names', 'varlabels', 'types')
