function[x] = stochgrad(objFun,x,data,labels,batchsize,eta,maxepoch,method,avgstart,maxIter)
nTrain = size(data, 1);
num_batches = ceil(nTrain/batchsize);
groups = repmat(1:num_batches,1,batchsize);
groups = groups(1:nTrain);
groups = groups(randperm(nTrain));
t = 1;
k = 1;
err = 0;
xavg = x;
noise = 0;
for i=1:num_batches
	batchdata{i} = data(groups == i,:);
	batchlabels{i} = labels(groups == i,:);
end
for i=1:maxepoch
	for b=1:num_batches
		bdata = batchdata{b};
		blabels = batchlabels{b};
		if (noise > 0)
		  bdata = bdata.*(rand(size(bdata)) > noise);
		end
		if (isequal(method,'SGD'))
			fprintf('epoch %d batch %d\r',i,b);
			[f,g] = objFun(x,bdata,blabels);
			x = x - eta*g;
			if (i >= avgstart)
				xavg = xavg - (1/t)*(xavg - x);
				t = t + 1;
			end
			err = err + f;
		else
			fprintf('epoch %d batch %d\n',i,b);
			options.method = method;
			options.maxIter = maxIter;
			x = minFunc(objFun,x,options,bdata,blabels);
			if (i >= avgstart)
				xavg = xavg - (1/t)*(xavg - x);
				t = t + 1;
			end
		end
		k = k + 1;
	end
	if (isequal(method,'SGD'))
		fprintf('end of epoch %d error %4.6f\n',i,err);
		err = 0;
	end
end
x = xavg;