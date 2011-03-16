function [AUC, cutoff] = rocPMTK(confidence, label)
% Compute ROC curve
% This is based on rocCardillo, by Giuseppe Cardillo
% confidence(i) is a real value
% label(i) is 0 or 1

%           Created by Giuseppe Cardillo
%           giuseppe.cardillo-edta@poste.it
%
% To cite this file, this would be an appropriate format:
% Cardillo G. (2008) ROC curve: compute a Receiver Operating Characteristics curve.
% http://www.mathworks.com/matlabcentral/fileexchange/19950

x = [confidence(:) label(:)];
threshold = 0; 
alpha = 0.05;
verbose = 1;


tr=repmat('-',1,80);
lu=length(x(x(:,2)==1)); %number of unhealthy subjects
lh=length(x(x(:,2)==0)); %number of healthy subjects
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
    xroc=flipud([1; 1-a(:,2); 0]); yroc=flipud([1; a(:,1); 0]); %ROC points
    labels=flipud(labels);
else
    xroc=[0; 1-a(:,2); 1]; yroc=[0; a(:,1); 1]; %ROC points
end

Area=trapz(xroc,yroc); %estimate the area under the curve
%standard error of area
if verbose
    subplot(1,2,1)
    HR1=plot(xroc,yroc,'r.-');
    hold on
    HRC1=plot([0 1],[0 1],'k');
    plot([0 1],[1 0],'g')
    hold off
    xlabel('False positive rate (1-Specificity)')
    ylabel('True positive rate (Sensitivity)')
    title('ROC curve')
    axis square
    
    subplot(1,2,2)
    HR2=plot(1-xroc,yroc,'r.-');
    hold on
    plot([0 1],[0 1],'g')
    HRC2=plot([0 1],[1 0],'k');
    hold off
    xlabel('True negative rate (Specificity)')
    ylabel('True positive rate (Sensitivity)')
    title('Mirrored ROC curve')
    axis square
    
    %if partest.m was downloaded
    if p<=alpha
        %the best cut-off point is the closest point to (0,1)
        d=realsqrt(xroc.^2+(1-yroc).^2); %apply the Pitagora's theorem
        [~,J]=min(d); %find the least distance
        co=labels(J-1); %Set the cut-off point
               
        subplot(1,2,1)
        hold on
        HCO1=plot(xroc(J),yroc(J),'bo');
        hold off
        legend([HR1,HRC1,HCO1],'ROC curve','Random classifier','Cut-off point','Location','NorthOutside')
        subplot(1,2,2)
        hold on
        HCO2=plot(1-xroc(J),yroc(J),'bo');
        hold off
        legend([HR2,HRC2,HCO2],'ROC curve','Random classifier','Cut-off point','Location','NorthOutside')
        disp(' ')
        fprintf('Cut-off point for best Sensitivity and Specificity (blu circle in plot)= %0.4f\n',co)
        disp('In the ROC plot, the cut-off point is the closest to [0,1] point or, if you want, the closest to the green line')
        disp('Press a key to continue'); pause
        %table at cut-off point
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
        cotable=[TP FP; FN TN];
        disp('Table at cut-off point')
        disp(cotable)
        disp(' ')
        try
            partest(cotable)
        catch ME
            disp(ME)
            disp('If you want to calculate the test performance at cutoff point please download partest.m from Fex')
            disp('http://www.mathworks.com/matlabcentral/fileexchange/12705')
        end
    end
end

AUC = Area;
cutoff = co;

if nargout

end
