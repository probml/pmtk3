function [X,y] = satDataLoad()

%stat = load('stat2.dat'); % Johnson and Albert p77 table 3.1

% This file is from pmtk3.googlecode.com

stat = loadData('sat'); % Johnson and Albert p77 table 3.1
% stat=[pass(0/1), 1, 1, sat_score, grade in prereq]
% where the grade in prereq is encoded as A=5,B=4,C=3,D=2,F=1
y = stat(:,1);
N = length(y);
X = [ones(N,1) stat(:,4)];

end
