%% Simple demo of Bayes factor computation
% We must work in log domain!


N=10; N1 = 9; logBF = nchoosekln(N, N1) + N*log(0.5) + log(N+1); BF=exp(-logBF)

N=100; N1 = 90; logBF = nchoosekln(N, N1) + N*log(0.5) + log(N+1); BF=exp(-logBF)