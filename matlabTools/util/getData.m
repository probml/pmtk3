function [data, nClass] = getData(name, options)
% newer version of processData
% get Data specified by name, plotHist, plotMI (mutual information).
% splits the data into test and train

  dirName = '/global/scratch/emtiyaz/datasets/';
  %dirName = '/cs/SCRATCH/emtiyaz/datasets/';

  [plotHist, plotMI, ratio] = myProcessOptions(options, 'plotHist',0,'plotMI',0, 'ratio', 0.7);
  switch name
  case {'mutualFunds','mutualFundsBinary'}
    Y = importdata([dirName 'mutualfunddata.txt']);
    % standardize
    Y = bsxfun(@minus, Y, mean(Y));
    Y = bsxfun(@times, Y, 1./std(Y));
    switch name
    case 'mutualFunds'
      data.continuous = Y';
      data.discrete = [];
    case 'mutualFundsBinary'
      data.continuous = [];
      data.discrete = (Y'>0)+1;
    end
    nClass = max(data.discrete,[],2);

  case 'caltechSil'
    load([dirName 'caltech101_silhouettes_16']);
    %classIdx = [1 2 94];
    classIdx = [1:4];
    idx = zeros(length(Y),1);
    for i = classIdx
      idx = or(idx, Y'== i);
    end
    idx = find(idx);
    X = X(idx,:)+1;
    data.continuous = [];
    % first value is the label
    data.discrete = [Y(idx)' X]';
    data.classIdx = classIdx;
    nClass = max(data.discrete,[],2);

  case {'newsgroups', 'newsgroupsSmall'}
    load([dirName 'a3newsgroups.mat']);
    % select class
    classId = 1;%there are 4 classes
    idx = find(newsgroups == classId);
    data.discrete = full(documents(:,idx)) + 1;
    %data.discrete = data.discrete(1:20,1:100);
    data.continuous = [];
    if strcmp(name, 'newsgroupsSmall')
      data.discrete = data.discrete(:,1:160);
    end
    nClass = max(data.discrete,[],2);
    data.names = wordlist;

  case {'ases', 'asesUK', 'asesFrance', 'asesGermany', 'asesDeveloping','asesDeveloped'}
    %a = importdata([dirName 'asesLarge.txt']);
    %Y = a.data;
    load([dirName 'ases.mat']);
    nMiss = sum(isnan(Y),1);
    % find variables with less than 1000 missing
    idx = find(nMiss <1000);
    % find fully ovserved measurements
    X = Y(:,idx);
    names = names(idx);
    idx = find(~sum(isnan(X),2));
    X = X(idx,:);
    % take a specific country
    switch name
    case 'ases'
      idx = find(X(:,2) == 2); 
    case 'asesUK'
      idx = find(X(:,1) == 10); 
    case 'asesFrance'
      idx = find(X(:,1) == 12); 
    case 'asesGermany'
      idx = find(X(:,1) == 13); 
    case 'asesDeveloping'
      idx = find(X(:,1) == 1); 
    case 'asesDeveloped'
      idx = find(X(:,2) == 2); 
    end
    X = X(idx,:);
    data.continuous = [];%X(:,2)';
    data.discrete = X(:,[3:44])';
    data.names = names(3:44);
    nClass = max(data.discrete,[],2);

  case {'sim1','sim2'}
    % make data
    N = 500;
    Dc = 5;
    % continuous data
    if strcmp(name, 'sim1')
      r = 0.0;
    else
      r = 0.6;
    end
    covMat = [1 r r 0 0; r 1 r r 0; r r 1 r r; 0 r r 1 r; 0 0 r r 1];
    Bc = eye(Dc);%rand(Dc,Dc);
    noise = 0.001;
    data.continuous = chol(covMat)*randn(Dc,N);
    data.discrete = (Bc*data.continuous + noise*randn(Dc,N))>0;
    data.discrete = data.discrete + 1;
    nClass = max(data.discrete,[],2);

  case 'cylinderBands'
    Y = importdata([dirName 'imputation/cylinderBands.data']);
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:);

    idxIrrelevant = [];%[17 25 28 29 36 37 38];
    idxRel = setdiff([1:40], idxIrrelevant);
    idxCont = [1:4 21:38];
    idxDis = setdiff(idxRel, idxCont);
    Y = X(:,idxCont);
    Y = (Y-repmat(mean(Y),size(Y,1),1))./repmat(std(Y),size(Y,1),1);
    X(:,idxCont) = Y;
    data.continuous = Y';
    Y = X(:,idxDis)';
    for d = 1:size(Y,1)
      val= unique(Y(d,:));
      Y(d,:) = arrayfun(@(v)find(v==val), Y(d,:));
    end
    X(:,idxDis) = Y';
    data.discrete = Y;
    save temp data

    nr = 5; nc = 8;
    simParams.missProb = 0.1;

  case 'creditApproval'
    Y = importdata([dirName 'imputation/creditApproval.data']);
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:);

    idxCont = [2 3 8 11 14 15];
    idxDis = setdiff([1:16], idxCont);
    Y = X(:,idxCont);
    Y = (Y-repmat(mean(Y),size(Y,1),1))./repmat(std(Y),size(Y,1),1);
    data.continuous = Y';
    data.discrete = X(:,idxDis)';
    nr = 4; nc = 4;

  case {'auto', 'autoSmall'}
    %Y = importdata('/global/scratch/emtiyaz/datasets/imputation/auto-mpg.data');
    Y = importdata([dirName 'imputation/auto-mpg.data']);
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:);
    names = {'mpg','cylinders', 'displacement','horsepower','weight','acceleration','modelYear','origin'};

    % recode cyclinder
    val= [3 4 5 6 8];
    X(:,2) = arrayfun(@(v)find(v==val), X(:,2));
    % recode years
    X(:,7) = X(:,7) - 69;
    % standardize continuous
    Y = X(:,[1 3 4 5 6]);
    Y = (Y-repmat(mean(Y),size(Y,1),1))./repmat(std(Y),size(Y,1),1);
    data.continuous = Y';
    data.discrete = X(:,[2 7 8])';
    if strcmp(name, 'autoSmall')
      data.continuous = data.continuous(:,1:200);
      data.discrete = data.discrete(:,1:200);
    end
    nClass = max(data.discrete,[],2);
    %names = {'mpg','displacement','horsepower','weight','acceleration','cylinders','modelYear','origin'};
    data.names = names([1 3 4 5 6 2 7 8]);

    simParams.missProb = 0.1;

  case {'adult', 'adultSmall'}
    train = textread([dirName 'AdultDataset/adultMatlab.txt']);
    test = textread([dirName 'AdultDataset/adultTestMatlab.txt']);
    names = {'age','workclass','fnlwgt','education','eduction_num','marital_status','occupation','relationship','race','sex','capital_gain','capital_loss','hrs_per_week', 'country','income'};
    % remove all the instances with missing data
    Y = [train; test];
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:)';
    type = 'cmcmcmmmmbcccmb';

    % fnlwgt : truncate, log transform, and standardize
    X(3,:) = log(X(3,:));% - mean(dataAll(3,:));
    X(13,:) = log(X(13,:));
    idxCont = [1 3 5 13];
    Y = X(idxCont,:)';
    Y = (Y-repmat(mean(Y),size(Y,1),1))./repmat(std(Y),size(Y,1),1);
    X(idxCont,:) = Y';
    % For Workclass: Coding is in the following way:
    % Federal-Gov, Local-Gov, Never-Worked, Private, Self-emp-inc,
    % sel-imp-not-inc, stat-gov, without pay.
    % make 3 categories: Gov employee (1), self-employed(2), others(3)  
    a = X(2,:);
    b = a;
    idx = find((a<=2)|(a==7)); 
    b(idx) = 1;
    idx = find(a==4); 
    b(idx) = 2;
    idx = find((a==3)|(a==5)|(a==6)|(a==8)); % 0 datapoint for nvever-worked
    b(idx) = 3;
    X(2,:) = b;

    % Marital status :
    % Cdding: Divorced, Married-AF-spouse, Married-civ-spouse,
    % Married-spouse-absent, never-married, separated, widowed
    % Recode: married, never married and others
    a = X(6,:);
    b = a;
    idx = find((a==2)|(a==3)|(a==4));
    b(idx) =1;
    idx = find(a==5);
    b(idx) =2;
    idx = find((a==1)|(a==6)|(a==7));
    b(idx) =3;
    X(6,:) = b;
    % hours per week: log transform and standardize
    idx = [1 2 3 5 7 8 10 13 15];%[1:3 5:13 15];
    X = X';
    data.continuous = X(:,idxCont)';
    idxDis = setdiff(idx, idxCont);
    data.discrete = X(:,idxDis)';

    if strcmp(name, 'adultSmall')
      data.continuous = data.continuous(:,1:200);
      data.discrete = data.discrete(:,1:200);
    end
    data.names = names([idxCont idxDis]);;
    X = X(:,idx);

    nr = 3; nc = 4;

  case 'german'
    Y = importdata([dirName 'imputation/german.data-numeric']);
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:);
    nr = 5; nc=5;
    
    Y = X(:,[2 4 10]);
    Y = Y - repmat(mean(Y), size(Y,1), 1);
    Y = Y./repmat(std(Y), size(Y,1),1);
    X(:,[2 4 10]) = Y;
    data.continuous = Y';
    X(:,[3 16:24]) = X(:,[3 16:24]) + 1;
    data.discrete = X(:,setdiff([1:25],[2 4 10]))';
    simParams.missProb = 0.1;

  case 'thyroid'
    Y = importdata([dirName 'imputation/thyroid.data']);
    idx = [1:27];
    idx1 = find(~sum(isnan(Y(:,idx)),2));
    X = Y(idx1,idx);
    idxCont = [1 18:2:27];
    idxDis = setdiff([1:27], idxCont);
    Y = X(:,idxCont);
    Y = (Y-repmat(mean(Y),size(Y,1),1))./repmat(std(Y),size(Y,1),1);
    data.continuous = Y';
    data.discrete = X(:,idxDis)';
    nClass = max(data.discrete,[],2);

    nr = 5; nc = 6;

  case 'coil'
    Y = csvread([dirName 'imputation/analysis.data']);
    idx = find(~sum(isnan(Y),2));
    X = Y(idx,:);
    names = {'season','river-size','fluid-velocity','obs1','obs2','obs3','obs4','obs5','obs6','obs7','obs8','algae1','algae2','algae3','algae4','algae5','algae6','algae7'};
    Y = X(:,[4:end]);
    Y = (Y-repmat(mean(Y),size(Y,1),1))./repmat(std(Y),size(Y,1),1);
    data.continuous = Y';
    data.discrete = X(:,[1 2 3])';
    nClass = max(data.discrete,[],2);
    data.names = names([4:end 1 2 3]);

    simParams.missProb = 0.1;
    nr = 4; nc=5;

  otherwise
    error('no such name');
  end

  X = [data.continuous; data.discrete]';
  if plotHist
    size(X)
    for i = 1:size(X,2)
    i
      %subplot(nr,nc,i)
      hist(X(:,i),20);
      %title(names{i})
      pause
    end
  end

  % keep only the dimensions which have more than 1 class 
  idx = [];
  for d = 1:size(data.discrete,1)
    if ~(length(unique(data.discrete(d,:)))==1)
      idx = [idx; d];
    end
  end
  data.discrete = data.discrete(idx,:);
  nClass = max(data.discrete,[],2);
  %if isfield(data, 'names')
  %  data.names = data.names(idx);
  %end

  if plotMI
    figure(1)
    mi = mutualInformation(data, [], 'quantiles',1);
    imagesc(mi);
    %set(gca,'xtick',[1:length(names)],'xticklabel',data.names);
    %set(gca,'ytick',[1:length(names)],'yticklabel',data.names);
    %rotateticklabel(gca,90);
    title('MI');
    colorbar;
    Dc = size(data.continuous,1);
    Dd = size(data.discrete,1);

    figure(2)
    mi(Dc+1:end, Dc+1:end) = 0; 
    imagesc(mi);
    colorbar
  end

