

%% Check the reasonableness of the local observation model 

% Data
loadData('sceneContextSUN09', 'ismatfile', false)
load('SUN09data')


train = data.train;
test = data.test;
objectnames = data.names;

[Ntrain, Nobjects] = size(train.presence);
[Ntest, Nobjects2] = size(test.presence);

obstypes = {'gauss', 'quantize'};

for oo=1:numel(obstypes)
  obstype = obstypes{oo};

labels = train.presence;
scores = train.detect_maxprob;
%[quantizedScores, discretizeParams] = discretizePMTK(scores, 10);
[obsmodel] = obsModelFit(labels, scores, obstype);


% we plot the distribution of scores for 2 classes

for c=[1 110]
  
  % Empirical distributon
  scores = train.detect_maxprob;
  ndx=(train.presence(:,c)==1);
  figure;
  subplot(2,2,1)
  [counts, bins]=hist(scores(ndx,c));
  binstr =cellfun(@(b) sprintf('%2.1f', b), num2cell(bins), 'uniformoutput', false);
  bar(counts); set(gca, 'xticklabel', binstr)
  title(sprintf('%s present, m %5.3f, v %5.3f', ...
    objectnames{c}, mean(scores(ndx,c)),var(scores(ndx,c))));
  
  subplot(2,2,2)
  [counts, bins] = hist(scores(~ndx,c));
  binstr =cellfun(@(b) sprintf('%2.1f', b), num2cell(bins), 'uniformoutput', false);
  bar(counts); set(gca, 'xticklabel', binstr)
  title(sprintf('%s absent, m %5.3f, v %5.3f', ...
    objectnames{c}, mean(scores(~ndx,c)), var(scores(~ndx,c))));
  
  % Model distribution
  
  switch obsmodel.obsType
    case 'gauss'
      xmin = min(scores(:,c));
      xmax = max(scores(:,c));
      xvals = linspace(xmin, xmax, 100);
      mu = squeeze(obsmodel.mu(1,:,c));
      Sigma = permute(obsmodel.Sigma(:,:,:,c), [3 4 1 2]);
      p = gaussProb(xvals, mu(2), Sigma(2));
      subplot(2,2,3)
      plot(xvals, p, 'b-');
      title(sprintf('model for %s presence', objectnames{c}))
      subplot(2,2,4)
      p = gaussProb(xvals, mu(1), Sigma(1));
      plot(xvals, p, 'r:');
      title(sprintf('model for %s absence', objectnames{c}))
    case 'quantize'
      % CPT(label, feature, node)
      subplot(2,2,3)
      bar(squeeze(obsmodel.CPT(2,:,c)))
      title(sprintf('model for %s presence', objectnames{c}))
      bins = obsmodel.discretizeParams.bins{c};
      binstr =cellfun(@(b) sprintf('%2.1f', b), num2cell(bins), 'uniformoutput', false);
      set(gca,'xticklabel', binstr)
      subplot(2,2,4)
      bar(squeeze(obsmodel.CPT(1,:,c)))
      title(sprintf('model for %s absence', objectnames{c}))
      set(gca,'xticklabel',binstr)
  end
end

end
