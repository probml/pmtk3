% Plots Regularization Path for L1L1/L1Linf/L1L2
clear all
close all

doL1 = 1;
doLinf = 1;
doL2_tau = 1;
doL2_lambda = 1;

%% Load Data
data = load('statlog.heart.data');
y = sign(data(:,end) - 1.5);
X = standardizeCols(data(:,1:end-1));
X = [ones(size(X,1),1) X];
[n,p] = size(X);
[nInstances,nVars] = size(X);

groups = [0 1 1 2 2 3 3 1 1 2 2 3 3 1]'; % Group 0 is unpenalized

%% L1L1

if doL1
    lambdaMax = 100;
    lambdaInc = 1;
    i = 1;
    w_init = zeros(p,1);
    clear w
    lambdaValues = lambdaMax:-lambdaInc:0;
    for lambda = lambdaValues
            lambdaVect = [0;lambda*ones(p-1,1)];
        w(:,i) = L1GeneralProjection(@LogisticLoss,w_init,lambdaVect,[],X,y);
        w_init = w(:,i);
        i = i + 1;
    end
    figure(1);
    h=plot(lambdaValues,w);
    set(h,'LineWidth',2);
    hTitle  = title ('L1(L1)');
    set( hTitle                    , ...
        'FontSize'   , 12          , ...
        'FontWeight' , 'bold'      );
    for i = 2:length(lambdaValues)
        if sum(abs(w(:,i)) > 1e-4) ~= sum(abs(w(:,i-1)) > 1e-4)
            h=vline(lambdaValues(i));
            set(h,'Color',[1 .5 .5],'LineWidth',1.5);
        end
    end
    fprintf('(paused)\n');
    pause;
end

%% L1Linf
if doLinf
tic
    lambdaMax = 250;
    lambdaInc = 2.5;
    w_init = zeros(p,1);
    clear w
    nGroups = length(unique(groups(groups>0)));
    lambdaValues = lambdaMax:-lambdaInc:0;
    

    
    i = 1;
    funObj = @(w)LogisticLoss(w,X,y);
    options.normType = inf;
    for lambda = lambdaValues
        w(:,i) = L1groupSPG(funObj,w_init,groups,lambda,options);
        w_init = w(:,i);
        i = i + 1;
    end
    figure(2);
    h=plot(lambdaValues,w);
    set(h,'LineWidth',2);
    hTitle  = title ('L1(Linf)');
    set( hTitle                    , ...
        'FontSize'   , 12          , ...
        'FontWeight' , 'bold'      );
    for i = 2:length(lambdaValues)
        if sum(abs(w(:,i)) > 1e-4) ~= sum(abs(w(:,i-1)) > 1e-4)
            h=vline(lambdaValues(i));
            set(h,'Color',[1 .5 .5],'LineWidth',1.5);
        end
    end
    fprintf('(paused)\n');
    toc
    pause;
end


%% L1L2
if doL2_lambda
tic
    lambdaMax = 150;
    lambdaInc = 1.5;
    w_init = zeros(p,1);
    clear w
    nGroups = length(unique(groups(groups>0)));
    lambdaValues = lambdaMax:-lambdaInc:0;
    
    i = 1;
    funObj = @(w)LogisticLoss(w,X,y);
    options.normType = 2;
    for lambda = lambdaValues
        w(:,i) = L1groupSPG(funObj,w_init,groups,lambda,options);
        w_init = w(:,i);
        i = i + 1;
    end
    figure(3);
    h=plot(lambdaValues,w);
    set(h,'LineWidth',2);
    hTitle  = title ('L1(L2) (lambda-path)');
    set( hTitle                    , ...
        'FontSize'   , 12          , ...
        'FontWeight' , 'bold'      );
    for i = 2:length(lambdaValues)
        if sum(abs(w(:,i)) > 1e-4) ~= sum(abs(w(:,i-1)) > 1e-4)
            h=vline(lambdaValues(i));
            set(h,'Color',[1 .5 .5],'LineWidth',1.5);
        end
    end
    fprintf('(paused)\n');
    toc
    pause;
end