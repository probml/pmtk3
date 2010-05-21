function [dag,wordlist] = getDAGalarm()
wordlist = {'1','2','3','4','5','6','7'};

dag = zeros(7);
dag(1,2) = 1;
dag(2,3) = 1;
dag(3,4) = 1;
dag(4,5) = 1;
dag(5,6) = 1;
dag(6,7) = 1;