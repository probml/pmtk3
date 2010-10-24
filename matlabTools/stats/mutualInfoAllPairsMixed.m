function [mi,nbins] = mutualInfoAllPairsMixed(XD,XC,varargin)
% compute the mutual information between discrete and cts variables. 
%[mi,nbins] = mutualInfoAllPairs(XD,XC,[levels,method,smoothing])
% XD is N*DD discrete data (can be [])
% XC is N*DC cts data (can be [])
% PMTKneedsStatsToolbox hist3
% optional arguments:
% - levels is a scalar giving the number of quatization levels to use for continuous data. 
%   The same number of levels is used for all data dimensions. Set levels to empty [] to use
%   a number of levels adaptively chosen for each dimension based on Scott's method for choosing the
%   bin widths.
% - method is the quantization method to use.
%     Can be 'uniform', 'kmeans', or 'quantile'. See quantizePMTK
% - smoothing is the amount that counts are smoothed when computing P(x,y)
%
% Output
% - mi is the estimated mutual information for all pairs of variables
% - nbins is the number of histogram bins chosen for each continuous dimension
%
% Note: if data is all discrete, this is equivalent to
% mutualInfoAllPairsDiscrete 

% This file is from pmtk3.googlecode.com


%PMTKauthor Emtiyaz Khan, Ben Marlin

if nargin < 2, XC = []; end
[levels, method, smoothing, useSpeedup, maxLevels] = process_options(varargin, ...
  'levels', [], 'method', 'quantiles', 'smoothing', 0, 'useSpeedup', true,...
  'maxLevels', 20);

%% Quantize continuous data
data.continuous = XC';
data.discrete = XD';
[DC,N]=size(data.continuous);
[DD,N]=size(data.discrete);
y     = zeros(DC+DD,N);
for i=1:size(data.continuous,1)
  if(isempty(levels))
    % Use Scott's (1979) method "On optimal and data-based histograms"
    l = floor(N^(1/3)*(max(data.continuous(i,:))-min(data.continuous(i,:)))/(3.5*std(data.continuous(i,:))));
    l = max(l,2);
  else
    l = max(round(levels),2);
  end
  l = min(l, maxLevels); % for speed
  nbins(i)=l;
  y(i,:) = quantizePMTK(data.continuous(i,:)','levels',l,'method',method);
end
y(DC+(1:DD),:) = data.discrete;

if useSpeedup
  mi = mutualInfoAllPairsDiscrete(y');
  return;
end

%% Slow way - Using D^2 for loops...
[D,N] = size(y);
mi = zeros(D,D);

for i = 1:D
  cntrs{i} = unique(y(i,:));
end

for i = 1:D
  for j = i+1:D
    pxy = hist3(y([i,j],:)',cntrs([i,j])) + smoothing;
    %set(get(gca, 'child'), 'FaceColor', 'interp', 'CDataMode', 'auto');
    pxy = pxy./sum(sum(pxy));
    px  = sum(pxy,1);   
    py  = sum(pxy,2);
    mi(i,j) = sum(sum(pxy.*(log(pxy) - bsxfun(@plus, log(px), log(py)))));
  end
end
mi = (mi + mi');
return
