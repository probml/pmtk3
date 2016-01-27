function mnistShow(images, labels)
% showMNIST Display MNIST digits; press button inside window to step through
% function showMNIST(images, labels)

if nargin < 2, labels = []; end

for k = 1:size(images,3)
  image(images(:,:,k))
  colormap gray, axis image off;
  if ~isempty(labels)
    title(num2str(double(labels(k))))
  end
  waitforbuttonpress;
end
