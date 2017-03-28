% logregGradeResiduals

%[X, y, bs, perm] = logregGradeMH();
[X, y, bs] = logregSatMhDemo(0);
perm = sortidx(X(:, 2), 'ascend');
SATscores = X(:,2);
%[X,y] = satDataLoad;
N = length(perm);


figure;
% posterior predictive residuals  A&J p97
for ii=1:N
  i = perm(ii);
  p1s = 1 ./ (1+exp(-X(i,:)*bs')); % p1s(s) = p(y=1|x(i,:), bs(s,:)edit log)
  p1 = mean(p1s); p0 = 1-p1; ppred = [p0, p1]; 
  ppredobs(i) = ppred(y(i)+1); % 0,1 -> 1,2
  h=plot(X(i,2), ppredobs(i), 'o'); 
  set(h,'markersize', 8);
  if ppredobs(i)<0.3
    set(h,'markerfacecolor','k');
  end
  hold on
end


suspiciousCases = find(ppredobs < 0.3)
disp('suspicious SAT scores')
disp(SATscores(suspiciousCases))

xlabel('SAT score')
ylabel('p(y_i|y)')
figure; bar(ppredobs); title('posterior predictive applied to observed data')
drawnow 
printPmtkFigure('logregSatPostPred')

% visualize model fit for each training point
figure;
hold on
for ii=1:N
    i = perm(ii);
    ps = 1 ./ (1+exp(-X(i,:)*bs')); % ps(s) = p(y=1|x(i,:), bs(s,:)) row vec
    plot(X(i,2), median(ps), 'ko');
    if ismember(i, suspiciousCases)
         h=plot(X(i,2), y(i), 'ro');
         set(h, 'markersize', 8, 'markerfacecolor', 'r')
    else
        h=plot(X(i,2), y(i), 'ko');
        set(h,'markerfacecolor', 'k');
    end
    % prediction interval
    tmp = sort(ps, 'ascend');
    Q5 = tmp(floor(0.05*Nsamples));
    Q95 = tmp(floor(0.95*Nsamples));
    line([X(i,2) X(i,2)], [Q5 Q95]);
end
printPmtkFigure('logregSatOutliers')



unif = rand(N,1);
figure;
qqplot(pred, unif);
xlabel('quantiles of uniform')
ylabel('quantiles of predictive distribution')



return

figure;
% cross-validation  residuals  A&J p99
Nsamples = size(bs,1);
for ii=1:N
  i = perm(ii);
  p1s = 1 ./ (1+exp(-X(i,:)*bs')); % p1s(s) = p(y=1|x(i,:), bs(s,:))
  p0s = 1-p1s; ps = [p0s; p1s];
  w = normalize(1./ps(y(i)+1,:));  % w(s) = 1/p(y(i)|x(i), beta(s))
  ndx = sampleDiscrete(w, 1, Nsamples);
  p1 = mean(p1s(ndx)); p0 = 1-p1;
  ppred = [p0, p1]; 
  ppredobsCV(i) = ppred(y(i)+1); % 0,1 -> 1,2
  h=plot(X(i,2), ppredobsCV(i), 'o'); 
  set(h,'markersize', 8);
  if ppredobsCV(i)<0.3
    set(h,'markerfacecolor','k');
  end
  drawnow 
  hold on
end
suspiciousCases = find(ppredobsCV < 0.3)
xlabel('SAT score')
ylabel('p(y_i|y(-i))')
figure; bar(ppredobsCV); title('CV predictive applied to observed data')

