  load autoData;
  setSeed(3);
  % number of latent variables
  Dz = 2;
  
 
  % CONTINUOUS DATA FA 
  % initialize 
   fprintf('\n\n*****demoFAemt cts\n\n')
  opt=struct('Dz', Dz);
  [params0, data] = initFA(data, [], opt);
  dataC = data; dataC.discrete = [];
  params0.a = 1;
  params0.b = 1;
  % Learn theta with EM algorithm 
  options = struct('maxNumOfItersLearn', 3,...
                    'lowerBoundTol', 1e-6,...
                    'estimateBeta',1,...% estimate loading factos
                    'estimateMean', 1,...% estimate prior mean (which is equivalent to estimating bias)
                    'estimateCovMat',0);
  funcName = struct('inferFunc', @inferFA, 'maxParamsFunc', @maxParamsFA);
  [params, logLik] = learnEm(dataC, funcName, params0, options);
  % Obtain p(z|y,\theta)
  [ss, logLik, postDist] = inferFA(data, params, []);
  factorsC = postDist.mean;
  
  figure(2);clf
  % PLOT
  [D,N] = size(data.continuous);
  nr = 2; nc =2;
  %colors = repmat([1:13]'/14, 1, 3).*repmat([1 1 1], 13, 1);
  count = 1;
  for i = [1 3]
    if i == 1
      colors = [0 0 0; 1/4 0 0; 2/4 0 0; 3/4 0 0; 1 0 0];
      markers = {'x','o','*','d','s'};
    elseif i == 3
      colors = [1 0 1; 0 1 0; 0 0 1];
      markers = {'o','d','s'};
    end
    subplot(nr,nc,count)
    hold on
    for j = 1:nClass(i)
      idx = find(data.discrete(i,:) == j);
      h(j) = plot(factorsC(1,idx), factorsC(2,idx),'o','color', colors(j,:),'marker',markers{j});
    end
    if i == 1
      legend('1','2','3','4','5','location','northwest');
      ht = title('Continuous-Data FA: #Cylinders');
    elseif i == 3
      legend('US','Europe','Japan','location','northwest');
      ht = title('Continuous-Data FA: Country');
    end
    hx = xlabel('Factor 1');
    hy = ylabel('Factor 2');
    %xlim([-3,3]);
    %ylim([-3,3]);

    set(gca,'fontname','Helvetica');
    set([hx,hy],'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out', 'ticklength',[.02 .02],'xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);

    clear h;
    count = count + 1;
  end


  
  fprintf('\n\n*****demoFAemt mixed\n\n')
  %MIXED-DATA FA 
  setSeed(3);
  % 1 of M encoding
  data.categorical = encodeDataOneOfM(data.discrete, nClass);
  % initialize
  opt=struct('Dz', Dz, 'nClass', nClass);
  [params0, data] = initMixedDataFA(data, [], opt);
  params0.a = 1;
  params0.b = 1;
  % learn theta with EM algorithm
  options = struct('maxNumOfItersLearn', 10,...
                    'lowerBoundTol', 1e-6,...
                    'estimateBeta',1,...% estimate loading factos
                    'estimateMean', 1,...% estimate prior mean (which is equivalent to estimating bias)
                    'estimateCovMat',0);
  funcName = struct('inferFunc', @inferMixedDataFA, 'maxParamsFunc', @maxParamsMixedDataFA);
  [params, logLik] = learnEm(data, funcName, params0, options);
  % Obtain p(z|y,\theta)
  params.psi = randn(size(data.categorical));% initialize variational parameters
  [ss, logLik, postDist] = inferMixedDataFA(data, params, []);
  factorsD = postDist.mean;

  figure(2);
  nr = 2; nc =2; count = 3;
  %colors = repmat([1:13]'/14, 1, 3).*repmat([1 1 1], 13, 1);
  for i = [1 3]
    if i == 1
      colors = [0 0 0; 1/4 0 0; 2/4 0 0; 3/4 0 0; 1 0 0];
      markers = {'x','o','*','d','s'};
    elseif i == 3
      colors = [1 0 1; 0 1 0; 0 0 1];
      markers = {'o','d','s'};
    end
    subplot(nr,nc,count)
    hold on
    for j = 1:nClass(i)
      idx = find(data.discrete(i,:) == j);
      h(j) = plot(factorsD(1,idx), factorsD(2,idx),'o','color',colors(j,:),'marker',markers{j});
    end
    if i == 1
      legend('1','2','3','4','5','location','northwest');
      ht = title('Mixed-Data FA: #Cylinders');
    elseif i == 3
      legend('US','Europe','Japan','location','northwest');
      ht = title('Mixed-Data FA: Country');
    end
    %ylim([-5 0]);
    %xlim([9.8 10.8]);
    hx = xlabel('Factor 1');
    hy = ylabel('Factor 2');
    set(gca,'fontname','Helvetica');
    set([hx,hy],'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out', 'ticklength',[.02 .02],'xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);

    clear h;
    count = count + 1;
  end
 % print -djpeg demoAutoFA2.jpeg

