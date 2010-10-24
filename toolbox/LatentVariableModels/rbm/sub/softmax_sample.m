
% This file is from pmtk3.googlecode.com

function[oneofn] = softmax_sample(probmat)
oneofn = zeros(size(probmat));
probmat = probmat./repmat(sum(probmat,2),1,size(probmat,2));
for i=1:size(probmat,1)
	probs = probmat(i,:);
	sample = cumsum(probs);
	sample = sample>rand();
	index = find(max(sample) == sample);
	index = min(index);
	sample = zeros(1,length(probs));
	sample(index) = 1;
	oneofn(i,:) = sample;
end
