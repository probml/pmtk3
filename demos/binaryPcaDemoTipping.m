% Demo of factor analysis applied to some synthetic binary data

% This file is from pmtk3.googlecode.com

%function [W, b, proto] = tippingDemo();

p = 16;
K = 3;
proto = rand(p,K) < 0.5;
data = [];
dataClean = [];
M = 50;
source = [1*ones(1,M) 2*ones(1,M) 3*ones(1,M)];
for k=1:K
  tmp = repmat(proto(:,k), 1, M);
  dataClean  = [dataClean tmp];
  noise = rand(p, M) < 0.05;
  tmp(noise) = 1-tmp(noise);
  data  = [data tmp];
end

figure; imagesc(data'); colormap(gray);printPmtkFigure('binaryPCAinput');
figure; imagesc(dataClean'); colormap(gray)

q = 2;
[W, b, muPost] = binaryPcaFitVarEm(data, 2);

figure;
symbols = {'ro', 'gs', 'k*'};
for k=1:K
  ndx = (source==k);
  plot(muPost(1,ndx), muPost(2,ndx), symbols{k});
  hold on
end
printPmtkFigure('binaryPCAoutput')
