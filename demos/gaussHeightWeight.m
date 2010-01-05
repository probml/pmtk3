%% Height Weight data in 2d

rawdata = dlmread('heightWeightData.txt'); % comma delimited file
data.Y = rawdata(:,1); % 1=male, 2=female
data.X = [rawdata(:,2) rawdata(:,3)]; % height, weight
maleNdx = find(data.Y == 1);
femaleNdx = find(data.Y == 2);
classNdx = {maleNdx, femaleNdx};
fnames = {'height','weight'};
classNames = {'male', 'female'};

figure;


for f=1:2
    %xrange = [0.9*min(data.X(:,f)) 1.1*max(data.X(:,f)];
    if f==1, xrange = [40 90]; else xrange = [50 300]; end
    for c=1:2
        X = data.X(classNdx{c}, f);
        pgauss{f,c} = fit(GaussDist(), 'data', X);
        subplot2(2,2,f,c);
        plot(pgauss{f,c}, 'xrange', xrange);
        title(sprintf('%s, %s', fnames{f}, classNames{c}));
        hold on
        mu = pgauss{f,c}.mu;
        pmu = exp(logprob(pgauss{f,c}, mu));
        line([mu mu], [0 pmu], 'color','r', 'linewidth', 2);
    end
end
