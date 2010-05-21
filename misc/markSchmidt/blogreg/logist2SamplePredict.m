function [yhat,bel] = logist2SamplePredict(X,samples)
% X(instance,feature)
% samples(feature,sample)
%
% yhat(instance,1)

[nInstances,nFeatures] = size(X);
[nFeatures,nSamples] = size(samples);

for i = 1:nInstances
    p = 0;
    for s = 1:nSamples
        p = p + logist2Bel(X(i,:),samples(:,s),0);
    end
    bel(i,1) = p/nSamples;
    yhat(i,1) = sign(bel(i,1)-.5);
end

