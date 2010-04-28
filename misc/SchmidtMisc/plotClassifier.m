function plotClassifier(X,y,w,method,kernelFunc,kernelArg)

[n,p] = size(X);

if p ~= 2 && p ~= 3
    fprintf('Plotting only supported for 2D data\n');
    return;
end

if size(w,2) ~= 1;
    multinomial = 1;
    nClasses = size(w,2)+1;
else
    multinomial = 0;
end

hold on
if multinomial
    colors = getColorsRGB;
    for c = 1:nClasses
        if p == 3
        plot(X(y==c,2),X(y==c,3),'.','color',colors(c,:));
        else
        plot(X(y==c,1),X(y==c,2),'.','color',colors(c,:));
        end
    end
else
    if p == 3
        plot(X(y==-1,2),X(y==-1,3),'b.');
        plot(X(y==1,2),X(y==1,3),'g.');
    else
        plot(X(y==-1,1),X(y==-1,2),'b.');
        plot(X(y==1,1),X(y==1,2),'g.');
    end
end
increment = 100;
domainx = xlim;
domain1 = domainx(1):(domainx(2)-domainx(1))/increment:domainx(2);
domainy = ylim;
domain2 = domainy(1):(domainy(2)-domainy(1))/increment:domainy(2);
d1 = repmat(domain1',[1 length(domain1)]);
d2 = repmat(domain2,[length(domain2) 1]);
if multinomial
    if size(w,1) == p
        if p == 3
        [junk yhat] = max([ones(numel(d1),1) d1(:) d2(:)]*w,[],2);
        else
            [junk yhat] = max([d1(:) d2(:)]*w,[],2);
        end
    else
       [junk yhat] = max(kernelFunc([d1(:) d2(:)],X,kernelArg)*w,[],2);
    end
else
    if length(w) == p
        if p == 3
            yhat = sign([ones(numel(d1),1) d1(:) d2(:)]*w);
        else
            yhat = sign([d1(:) d2(:)]*w);
        end
    elseif size(w,1) == n
        yhat = sign(kernelFunc([d1(:) d2(:)],X,kernelArg)*w);
    else
        yhat = sign(MLPregressionPredict(w,[ones(numel(d1),1) d1(:) d2(:)],kernelFunc));
    end
end
z = reshape(yhat,size(d1));

if multinomial
    u = unique(z(:));
    % For plotting purposes, remove classes that don't occur
    for c = nClasses:-1:1
       if ~any(z(:)==c)
           z(z > c) = z(z > c)-1;
       end
    end
    cm = colors(u,:)/2;
    colormap(cm);
    contourf(d1,d2,z,1:max(z(:)),'k');
else
contourf(d1,d2,z+rand(size(z))/1000,[-1 0],'k');
colormap([0 0 .5;0 .5 0]);
end

if multinomial
    colors = getColorsRGB;
    for c = 1:nClasses
        if p == 3
        plot(X(y==c,2),X(y==c,3),'.','color',colors(c,:));
        else
        plot(X(y==c,1),X(y==c,2),'.','color',colors(c,:));
        end
    end
else
    if p == 3
        plot(X(y==-1,2),X(y==-1,3),'b.');
        plot(X(y==1,2),X(y==1,3),'g.');
    else
        plot(X(y==-1,1),X(y==-1,2),'b.');
        plot(X(y==1,1),X(y==1,2),'g.');
    end
end
xlim(domainx);
ylim(domainy);
%legend({'Class 1','Class 2',method});
title(method);


end