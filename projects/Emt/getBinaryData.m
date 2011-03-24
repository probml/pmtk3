function Y = getBinaryData(name, options)

  dirName = myProcessOptions(options,'dirName','/cs/SCRATCH/emtiyaz/datasets/');
  %{
  % output filename
  [ret, hostname] = system('hostname');
  if strcmp(hostname(1:end-1), 'okanagan') | strcmp(hostname(1:end-1), 'moretti') | strcmp(hostname(1:end), 'bruna')
    dirName = '/cs/SCRATCH/emtiyaz/datasets/';
  else
    dirName = '/global/scratch/emtiyaz/datasets/';
  end
  %}

  [plotHist, plotMI, ratio] = myProcessOptions(options, 'plotHist',0,'plotMI',0, 'ratio', 0.7);
  switch name
  case 'tipping'
    load syntheticData1;
    Y = X';
    %[D,N] = size(Y);
    %idx = randperm(N);
    %Y = Y(:,idx(1:100));

  case 'trivial'
    proto = [1 0 1 1; 0 1 0 0]';
    Y =  [repmat(proto(:,1), 1,100) repmat(proto(:,2), 1,100)];
    %noise = rand(size(Y))>0.95;
    %Y(noise) = ~Y(noise);

  case 'small'
    true_params.D=4;
    %true_params.covMat = diag([1 1 1 1]);
    true_params.covMat = diag([.1 2 5 3]);
    true_params.covMat(4,3)=2;
    true_params.covMat(3,4)=2;
    true_params.mean = [1 0 1 -1]';
    %true_params.covMat(4,3)=0.9;
    %true_params.covMat(3,4)=0.9;
    %true_params.covMat(1,2)=0.9;
    %true_params.covMat(2,1)=0.9;
    %true_params.mean = [0 0 0 0]';
    true_params.beta = eye(true_params.D);
    true_params.precMat =inv(true_params.covMat);
    S  = 1000;
    z  = mvnrnd(true_params.mean,true_params.covMat,S);
    az = sigmoid(true_params.beta*z')';
    Yall = az>rand(S,true_params.D);
    Y = Yall';

  case 'ar1'
    D = 5;
    true_params.D=D;
    true_params.mean = zeros(D,1);
    true_params.covMat = diag(ones(D,1));
    for i = 1:D-1
      true_params.covMat(i,i+1) = 0.5;
      true_params.covMat(i+1,i) = 0.5;
    end
    true_params.beta = eye(D);
    true_params.precMat =inv(true_params.covMat);
    S  = 10000;
    z  = mvnrnd(true_params.mean,true_params.covMat,S);
    az = sigmoid(true_params.beta*z')';
    Yall = az>rand(S,true_params.D);
    Y = Yall';

  case 'synth5'

    D=5;
    true_params.D=D;
    true_params.mean = [2 1 0.5 0 0]';%zeros(D,1);
    %{
    a=0.1;
    C = eye(5);
    C = C + full(spdiags(ones(5,1)-a,1,5,5)) + full(spdiags(ones(5,1)-a,-1,5,5)) ;
    C(3:end,1)=-0.8;
    C(1,3:end)=-0.8;
    %}

    %(
    X1 = eye(3); X2 = [0 0; 0 1; 1 0; 1 1];
    X=[X1(repmat(1:3,4,1),:), repmat(X2,[3,1])];
    C=7*cov(X)+eye(D);
    %}

    X1 = [1 1 1; 0 0 0]; X2 = [0 0; 0 1; 1 0; 1 1];
    X=[X1(repmat(1:2,4,1),:), repmat(X2,[2,1])];
    C=7*cov(X)+eye(D);
    
    true_params.covMat =C;
    true_params.beta = eye(D);
    true_params.precMat =inv(true_params.covMat);

    S  = 100000;
    z  = mvnrnd(true_params.mean,true_params.covMat,S);
    az = sigmoid(true_params.beta*z')';
    Yall = az>rand(S,true_params.D);
    Y = Yall';
    %{
    [Y,I,J]  = unique(Yall,'rows'); 
    wY = hist(J,1:size(Y,1))/S;
    bar(wY)
    Y'
    pause
    %}

  case 'voting-84'
    Y = csvread([dirName 'binary/house-votes-84.txt']);
    Y = Y(:,[1:2 4:10 13:17])';
    idx = find(~sum(isnan(Y),1));
    Y = Y(:,idx);

  case 'voting-84-missing'
    Y = csvread([dirName 'binary/house-votes-84.txt']);
    Y = Y';

  case 'chainData'
    load([dirName 'binary/chainData.mat']);
    Y = y'-1;

  case 'VOC2006'
    load([dirName 'binary/VOC2006.mat']);
    Y = (X'+1)/2;
    %Y = Y(:,1:1000);

  case 'VOC2007'
    load([dirName 'binary/VOC2007.mat']);
    Y = (X'+1)/2;

  case 'johnsonEducation'
    X = importdata([dirName 'binary/educ1.dat']);
    Y = X(:,[1 4:8])';
    %load([dirName 'binary/johnson.Education.mat']);
    %Y = X';

  case 'uciLED'
    load([dirName 'binary/uci.led17.mat']);
    Y = X';

  case {'newsgroups'}
    load([dirName 'a3newsgroups.mat']);
    % select class
    classId = 1;%there are 4 classes
    idx = find(newsgroups == classId);
    Y = full(documents(:,idx));
    if strcmp(name, 'newsgroupsSmall')
      Y = Y(1:100,1:500);
    end

  case 'caltechSil'
    load([dirName 'caltech101_silhouettes_16']);
    %classIdx = [1 2 94];
    classIdx = 1;%[1:4];
    idx = zeros(length(Y),1);
    for i = classIdx
      idx = or(idx, Y'== i);
    end
    idx = find(idx);
    X = X(idx,:);
    % first value is the label
    %Y1 = [Y(idx)' X]';
    Y = X';

  case 'mutualFunds'
    Y = importdata([dirName 'mutualfunddata.txt']);
    % standardize
    Y = bsxfun(@minus, Y, mean(Y));
    Y = bsxfun(@times, Y, 1./std(Y));
    Y = (Y'>0);

  otherwise
    error('no such name');
  end

  %{
  % keep only the dimensions which have more than 1 class 
  idx = [];
  for d = 1:size(data.discrete,1)
    if ~(length(unique(data.discrete(d,:)))==1)
      idx = [idx; d];
    end
  end
  data.discrete = data.discrete(idx,:);
  %}

  if plotMI
    figure(1)
    data.continuous = [];
    data.discrete = Y;
    mi = mutualInformation(data, [], 'quantiles',1);
    imagesc(mi);
    %set(gca,'xtick',[1:length(names)],'xticklabel',data.names);
    %set(gca,'ytick',[1:length(names)],'yticklabel',data.names);
    %rotateticklabel(gca,90);
    title('MI');
    colorbar;
  end

