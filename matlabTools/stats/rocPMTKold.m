function [AUC, cutoff, EER, fpr, tpr] = rocPMTK(confidence, label)
% Compute ROC curve
% confidence(i) is a real value
% label(i) is 0 or 1
%
% AUC is area under curve
% cutoff is the threshold that gives equal error rate (EER)
% EER is the fpr=tpr at cutoff
% fpr(t) is false positive rate for threshold t (x axis)
% tpr(t) is true positive rate for threshold t (y axis)


%PMTKauthor Giuseppe Cardillo, 
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/19950
%PMTKmodified Kevin Murphy

x = [confidence(:) label(:)];
threshold = 0; 

z=sortrows(x,1);
if threshold==0
    labels=unique(z(:,1));%find unique values in z
else
    K=linspace(0,1,threshold+1); K(1)=[];
    labels=quantile(unique(z(:,1)),K)';
end
ll=length(labels); %count unique value
a=zeros(ll,2); %array preallocation
ubar=mean(x(x(:,2)==1),1); %unhealthy mean value
hbar=mean(x(x(:,2)==0),1); %healthy mean value
for K=1:ll
    if hbar<ubar
        TP=length(x(x(:,2)==1 & x(:,1)>labels(K)));
        FP=length(x(x(:,2)==0 & x(:,1)>labels(K)));
        FN=length(x(x(:,2)==1 & x(:,1)<=labels(K)));
        TN=length(x(x(:,2)==0 & x(:,1)<=labels(K)));
    else
        TP=length(x(x(:,2)==1 & x(:,1)<labels(K)));
        FP=length(x(x(:,2)==0 & x(:,1)<labels(K)));
        FN=length(x(x(:,2)==1 & x(:,1)>=labels(K)));
        TN=length(x(x(:,2)==0 & x(:,1)>=labels(K)));
    end
    a(K,:)=[TP/(TP+FN) TN/(TN+FP)]; %Sensitivity and Specificity
end

if hbar<ubar
    xroc=flipud([1; 1-a(:,2); 0]);
    yroc=flipud([1; a(:,1); 0]); 
    labels=flipud(labels);
else
    xroc=[0; 1-a(:,2); 1];
    yroc=[0; a(:,1); 1]; 
end

fpr = xroc;
tpr = yroc;
ndx = find(isnan(fpr)); fpr(ndx) = []; tpr(ndx) = [];
ndx = find(isnan(tpr)); fpr(ndx) = []; tpr(ndx) = [];


AUC = trapz(xroc,yroc); %estimate the area under the curve

%the best cut-off point is the closest point to (0,1)
d=realsqrt(xroc.^2+(1-yroc).^2); %pythagoras's theorem
[~,J]=min(d); %find the least distance
cutoff =labels(J-1); 
co = cutoff;
               
% performance at EER point
if hbar<ubar
  TP=length(x(x(:,2)==1 & x(:,1)>co));
  FP=length(x(x(:,2)==0 & x(:,1)>co));
  FN=length(x(x(:,2)==1 & x(:,1)<=co));
  TN=length(x(x(:,2)==0 & x(:,1)<=co));
else
  TP=length(x(x(:,2)==1 & x(:,1)<co));
  FP=length(x(x(:,2)==0 & x(:,1)<co));
  FN=length(x(x(:,2)==1 & x(:,1)>=co));
  TN=length(x(x(:,2)==0 & x(:,1)>=co));
end

FPR = FP/(FP+TN);
EER = FPR;

end
