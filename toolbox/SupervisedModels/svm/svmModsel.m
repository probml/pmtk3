function [X,Y,Z,hC] = modsel(label,inst)
% Model selection for (lib)SVM by searching for the best param on a 2D grid
% example:
%
% load heart_scale.mat
% [X,Y,Z,hC] = modsel(heart_scale_label,heart_scale_inst);
%
% where X,Y,Z are the contour data and hC is the contour handle

%PMTKurl http://agbs.kyb.tuebingen.mpg.de/km/bb/showthread.php?tid=855

%contour plot
fold = 10;
c_begin = -5; c_end = 15; c_step = 2;
g_begin = 3; g_end = -15; g_step = -2;
bestcv = 0;
bestc = 2^c_begin;
bestg = 2^g_begin;
i = 1; j = 1;
for log2c = c_begin:c_step:c_end
    for log2g = g_begin:g_step:g_end
        cmd = ['-v ',num2str(fold),' -c ',num2str(2^log2c),' -g ',num2str(2^log2g)];
        cv = svmtrain(label,inst,cmd);
        if (cv > bestcv) || ((cv == bestcv) && (2^log2c < bestc) && (2^log2g == bestg))
            bestcv = cv; bestc = 2^log2c; bestg = 2^log2g;
        end
        disp([num2str(log2c),' ',num2str(log2g),' (best c=',num2str(bestc),' g=',num2str(bestg),' rate=',num2str(bestcv),'%)'])
        Z(i,j) = cv;
        j = j+1;
    end
    j = 1;
    i = i+1;
end
xlin = linspace(c_begin,c_end,size(Z,1));
ylin = linspace(g_begin,g_end,size(Z,2));
[X,Y] = meshgrid(xlin,ylin); 
Z = Z';
acc_range = (ceil(bestcv)-3.5:.5:ceil(bestcv));
warning off all
[C,hC] = contour('v6',X,Y,Z,acc_range);

%legend plot
tmp = cell2mat(get(hC,'UserData'));
[M,N] = unique(tmp);
c = setxor(N,1:length(tmp));
for i = 1:length(N)
    set(hC(N(i)),'DisplayName',num2str(acc_range(i)))
end
for i = 1:length(c)
    set(get(get(hC(c(i)),'Annotation'),'LegendInformation'),'IconDisplayStyle','Off')
end
legend('show')  

%bullseye plot
hold on;
plot(log2(bestc),log2(bestg),'o','Color',[0 0.5 0],'LineWidth',2,'MarkerSize',15); 
axs = get(gca);
plot([axs.XLim(1) axs.XLim(2)],[log2(bestg) log2(bestg)],'Color',[0 0.5 0],'LineStyle',':')
plot([log2(bestc) log2(bestc)],[axs.YLim(1) axs.YLim(2)],'Color',[0 0.5 0],'LineStyle',':')
hold off;
title({['Best log2(C) = ',num2str(log2(bestc)),',  log2(gamma) = ',num2str(log2(bestg)),',  Accuracy = ',num2str(bestcv),'%'];...
    ['(C = ',num2str(bestc),',  gamma = ',num2str(bestg),')']})
xlabel('log2(C)')
ylabel('log2(gamma)')

