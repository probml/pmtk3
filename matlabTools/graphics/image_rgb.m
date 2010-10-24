function image_rgb(M)
% Show a matrix of integers as a color image.
% This is like imagesc, except we know what the mapping is from integer to color.
% If entries of M contain integers in {1,2,3,4,5}, we map
% this to red/green/blue/aquamarine/black.
% So if we call image_rgb on 2 different matrices,
% we always know black means 5.
% If we use imagesc, the mapping from color to number depends on the image.
% eg M=sampleDiscrete(normalize(ones(1,5)), 10,10); image_rgb(M);colorbar

% This file is from pmtk3.googlecode.com


cmap = [1 0 0; % red
	0 1 0; % green
	0 0 1; % blue
	127/255 1 212/255; % aquamarine
	0 0 0]; % black
image(M)
set(gcf,'colormap', cmap);
if max(unique(M(:))) > size(cmap,1)
  error(sprintf('can only support %d colors', size(cmap,1)))
end

if 0
  % make dummy handles, one per object type, for the legend
  str = {};
  for i=1:size(cmap,1)
    dummy_handle(i) = line([0 0.1], [0 0.1]);
    set(dummy_handle(i), 'color', cmap(i,:));
    set(dummy_handle(i), 'linewidth', 2);
    str{i} = num2str(i);
  end
  legend(dummy_handle, str, -1);
end

if 0
[nrows ncols] = size(M);
img = zeros(nrows, ncols, 3);
for r=1:nrows
  for c=1:ncols
    q = M(r,c);
    img(r,c,q) = 1;
  end
end
image(img)
end

end
