load 20news_w100
docs = double(documents);
sigma = full(docs*docs');%/16242;
AM = L1precisionBCD(sigma,1);
AM(abs(AM) < 1e-4) = 0;
AM2 = sign(AM);
drawGraph(abs(AM2),'labels',wordlist);