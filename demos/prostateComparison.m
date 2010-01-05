clear all
close all

load('prostate.mat') % from prostateDataMake
%load('housing.mat') % from housingDataMake
[n d] = size(X);
ndxTrain = find(istrain);
%ndxTrain = 1:n;
ndxTest = setdiff(1:n, ndxTrain);


% %%% exercise - implement prostateLS and prostateRidge
[mseTestLS, wLS] = prostateLS(X, y, ndxTrain, ndxTest);
[mseTestRidge, wRidge] = prostateRidge(X, y, ndxTrain, ndxTest);;
%%% 

[mseTestSS, wSS] = prostateSubsets(X, y, ndxTrain, ndxTest);;
[mseTestLasso, wLasso] = prostateLasso(X, y, ndxTrain, ndxTest);;
%[mseTestElastic, wElastic] = prostateElastic(X, y, ndxTrain, ndxTest);;

if 1
fprintf('%10s %7s %7s %7s %7s\n',...
	'Term', 'LS', 'Subset', 'Ridge', 'Lasso');
fprintf('%10s %7.3f %7.3f %7.3f %7.3f\n',...
	'intercept', wLS(1), wSS(1), wRidge(1), wLasso(1));
for i=1:d
  fprintf('%10s %7.3f %7.3f %7.3f %7.3f\n',...
	  names{i}, wLS(i+1), wSS(i+1), wRidge(i+1), wLasso(i+1));
end  
fprintf('\n%10s %7.3f %7.3f %7.3f %7.3f\n',...
	'Test MSE', mseTestLS, mseTestSS, mseTestRidge, mseTestLasso);
end



if 1
  % Latex table
fprintf('%7s & %7s & %7s&  %7s & %7s \\\\ \n',...
	'Term', 'LS', 'Subset', 'Ridge', 'Lasso');
fprintf('%10s & %7.3f & %7.3f &  %7.3f &  %7.3f \\\\ \n',...
	'intercept', wLS(1), wSS(1), wRidge(1), wLasso(1));
for i=1:d
  fprintf('%10s & %7.3f & %7.3f &  %7.3f &  %7.3f \\\\ \n',...
	  names{i}, wLS(i+1), wSS(i+1), wRidge(i+1), wLasso(i+1));
end  
fprintf('\\hline \\\\ \n');
fprintf('%10s & %7.3f & %7.3f &  %7.3f &  %7.3f \\\\ \n',...
	'Test MSE', mseTestLS, mseTestSS, mseTestRidge, mseTestLasso);
end



if 0
fprintf('%10s %7s %7s %7s %7s %7s\n',...
	'Term', 'LS', 'Subset', 'Ridge', 'Lasso', 'Enet');
fprintf('%10s %7.3f %7.3f %7.3f %7.3f %7.3f\n',...
	'intercept', wLS(1), wSS(1), wRidge(1), wLasso(1), wElastic(1));
for i=1:d
  fprintf('%10s %7.3f %7.3f %7.3f %7.3f %7.3f\n',...
	  names{i}, wLS(i+1), wSS(i+1), wRidge(i+1), wLasso(i+1), wElastic(i+1));
end  
fprintf('\n%10s %7.3f %7.3f %7.3f %7.3f %7.3f\n',...
	'Test MSE', mseTestLS, mseTestSS, mseTestRidge, mseTestLasso, mseTestElastic);

end
