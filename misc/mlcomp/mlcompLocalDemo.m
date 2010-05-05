%% 

localdir = tempdir(); %'C:\users\matt\desktop'; 
stat = load('satData.txt');
X = stat(:, 4); 
y = stat(:, 1) + 1; 
mlcompWriteData(X, y, fullfile(localdir, 'data')); 
mlcompCompiler('logregFit', 'logregPredict', localdir);
cd(localdir);
system(sprintf('octave -qf run learn data'));
system(sprintf('octave -qf run predict data yhat'));
yhat = str2double(getText('yhat'));
nerrs = sum(yhat ~= y)


%% Compare against matlab version
model = logregFit(X, y); 
yhat  = logregPredict(model, X); 
nerrs = sum(yhat ~= y)