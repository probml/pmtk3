%% All subsets regression
%
%%

% This file is from pmtk3.googlecode.com

setSeed(0);
%N = 20; 
N = 10;
D = 10;
w = randn(D,1);
ndx = randperm(D);
w(ndx(1:5))=0;
keep = find(w ~= 0);
%X = randn(N,D);
Sigma = randpd(D);
mu = randn(D,1);
model = struct('mu', mu, 'Sigma', Sigma);
X = gaussSample(model, N);
sigma = 1;
y = X*w + sigma*randn(N,1);

%{
loadData('prostate') % from prostateDataMake
[N,D] = size(X);
sigma = 1;
%}

numofmodel = 2^D;
sigmaPrior = 100; % variance of included weights
bitPrior = 0.1;
score = zeros(1, numofmodel);
Models = zeros(numofmodel, D);
for i= 1:numofmodel
   if i==1
      s = zeros(1,D);
   else
      s = graystep(s, 1);
   end
   Models(i,:) = s;
   Rs = diag(sigmaPrior*s);
   norm0 = sum(s);
   Phi1Inv = inv(X*Rs*X' + sigma*eye(N,N));
   scoreSS(i) = - 0.5*y'*Phi1Inv*y + 0.5*log(det(Phi1Inv))- 0.5*N*log(2*pi) ...
      + norm0*(log(bitPrior) - log(1-bitPrior)) + N*log(1-bitPrior);
end



figure
imagesc(Models');
colormap gray
printPmtkFigure('grayCodeModelsGray')

figure
plot(scoreSS);
title('log p(model, data)')
axis_pct
printPmtkFigure('grayCodeLogpost')

post = exp(normalizeLogspace(scoreSS));
figure;
stem(post)
%axis_pct
axis([-5 numofmodel+5 0 0.1])
title('p(model|data)')
printPmtkFigure('grayCodePost')

marg = sum(Models .* repmat(post(:), 1, D), 1);
figure; 
bar(marg)
title('p(gamma(j)|data')
printPmtkFigure('grayCodeMarg')

fprintf('top models\n');
[post, perm] = sort(post, 'descend');
Models = Models(perm,:);
ndx = find(post>=0.01);
for i=1:length(ndx)
   m = perm(i);
   fprintf('p(%d)=%5.3f: ', m, post(i));
   fprintf('%d ', find(Models(i,:)))
   fprintf('\n')
   table{i,1} = m;
   table{i,2} = post(i);
   table{i,3} = sprintf('%d, ', find(Models(i,:)));
end
latextable(table, 'horiz', {'model', 'prob', 'members'}, ...
  'hline', 1, 'name', [], 'format', '%5.3f')

fprintf('true weight vector\n');
fprintf('%4.2f, ', w); fprintf('\n')


