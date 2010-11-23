%% Reproduce figures 1,2,3 from Bolasso: Model Consistent Lasso Estimation
% throught the Bootstrap, by Francis R. Bach.
%%
%PMTKreallySlow

% This file is from pmtk3.googlecode.com

seed = 2008;
rand('twister',seed);randn('state',seed);
if(exist('bolassoDemoResults.mat','file'))
    fprintf('loading data from file...\n');
    load bolassoDemoResults.mat;
else

fprintf('generating new data, this might take a while...\n');
n = 1000;        %number of data points
d = 16;          %number of features
r = 8;           %number of relevant features 
nexpReps = 256;  %number of experiment replications. 

%values for the number of bootstrap replications. 0 indicates Lasso.
nbootstraps = [0,2,4,8,16,32,64,128,256]; 
ct = 1;  %consensusThreshold
lassoNDX = 1;
boot128NDX = 8;


lambda = exp(-15:0.2:0);

[Xc,yc,WloadingC] = bolassoMakeData(n,d,r,nexpReps,true);       %Lasso path consistent
[Xnc,ync,WloadingNC] = bolassoMakeData(n,d,r,nexpReps,false);    %Lasso path inconsistent



resultsC = false(nexpReps,numel(lambda),d,numel(nbootstraps));
resultsNC = false(nexpReps,numel(lambda),d,numel(nbootstraps));

for i=1:nexpReps
 
    resultsC(i,:,:,:) = bolasso(Xc{i},yc{i},'nbootstraps',nbootstraps,'lambda',lambda,'returnType','all','consensusThreshold',ct,'plotResults',false);
    resultsNC(i,:,:,:) = bolasso(Xnc{i},ync{i},'nbootstraps',nbootstraps,'lambda',lambda,'returnType','all','consensusThreshold',ct,'plotResults',false);
    fprintf(['Rep: ',num2str(i),'\n']);
 
end



%Take the average of all of the experiments for nbootstraps = [0,128]
meanResultsC = squeeze(mean(resultsC(:,:,:,[lassoNDX,boot128NDX]),1));
meanResultsNC = squeeze(mean(resultsNC(:,:,:,[lassoNDX,boot128NDX]),1));

correctSupport = [true(1,8),false(1,8)]';
correctC = zeros(numel(lambda),numel(nbootstraps));
correctNC = zeros(numel(lambda),numel(nbootstraps));
for boot=1:numel(nbootstraps)
    correctCtmp =  zeros(nexpReps,numel(lambda));
    correctNCtmp = zeros(nexpReps,numel(lambda)); 
    for ex=1:nexpReps
      for lam=1:numel(lambda)
          if(isequal(squeeze(resultsC(ex,lam,:,boot)) ,correctSupport))
              correctCtmp(ex,lam) = correctCtmp(ex,lam) + 1;
          end
          if(isequal(squeeze(resultsNC(ex,lam,:,boot)) ,correctSupport))
              correctNCtmp(ex,lam) = correctNCtmp(ex,lam) + 1;
          end
      end
    end
    correctC(:,boot) = mean(correctCtmp,1);
    correctNC(:,boot) = mean(correctNCtmp,1);
end

save bolassoDemo1Results;

end


%plot figure 1
f1 = figure;
image(-log(lambda),1:d,meanResultsC(:,:,1)','CDataMapping','scaled');
title('lasso on sign consistent data');
f2 = figure;
image(-log(lambda),1:d,meanResultsNC(:,:,1)','CDataMapping','scaled');
title('lasso on sign inconsistent data');
%plot figure 2
f3 = figure;
image(-log(lambda),1:d,meanResultsC(:,:,2)','CDataMapping','scaled');
title({'bolasso on sign consistent data';'128 bootstraps'});
f4 = figure;
image(-log(lambda),1:d,meanResultsNC(:,:,2)','CDataMapping','scaled');
title({'bolasso on sign inconsistent data';'128 bootstraps'});


figs = [f1,f2,f3,f4];
for i=1:numel(figs)
   figure(figs(i));
   colormap gray;
   colorbar;
   xlabel('-log(\lambda)','FontSize',14);
   ylabel('variable index','FontSize',14);
   set(gca,'FontSize',12);
   pdfcrop;
end

%plot figure 3
f5 = figure;
lasso = plot(-log(lambda),correctC(:,lassoNDX),'-k','LineWidth',2.5); hold on;
bolasso = plot(-log(lambda),correctC(:,2:end),'--r','LineWidth',2.5);

title({'lasso vs bolasso on sign consistent data'; 'nbootstraps = [0,2,4,8,16,32,64,128,256]'});
f6 = figure;
lasso = plot(-log(lambda),correctNC(:,lassoNDX),'-k','LineWidth',2.5); hold on;
bolasso = plot(-log(lambda),correctNC(:,2:end),'--r','LineWidth',2.5);

title({'lasso vs bolasso on sign inconsistent data'; 'nbootstraps = [0,2,4,8,16,32,64,128,256]'});

figs2 = [f5,f6];
for i=1:numel(figs2)
    figure(figs2(i));
    xlabel('-log(\lambda)','FontSize',14);
    ylabel('P(correct support)','FontSize',14);
    axis([0,15,0,1]);
    set(gca,'YTick',0:0.5:1,'FontSize',12);
    legend(gca,[lasso,bolasso(1)],{'lasso','bolasso'},'Location','NorthEast');
    pdfcrop;
end
    
    
