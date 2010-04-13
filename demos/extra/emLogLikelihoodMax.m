function emLogLikelihoodMax
%% Visualize EM Lower Bounds
f1 = @(x) log(normpdf(x,0,0.25))+1;
f2 = @(x) log(normpdf(x,1,0.2))+20;
f3 = @(x) 5*sin(2*(x-0.5)) + f1(0.5*x) + f2(0.5*x)+ 3.5+20*normpdf(x,-2,0.5)-20*normpdf(x,3,1) -70*normpdf(x,4,0.5) + 40*normpdf(x,-3,0.5)+100*normpdf(x,-4,0.8)+10*normpdf(x,3,0.3)-10*normpdf(x,-2.8,0.5);
domain = -5:0.01:5;
figure; hold on;
p1 = plot(domain,f1(domain),'-b','LineWidth',3);
p2 = plot(domain,f2(domain),':g','LineWidth',3);
p3 = plot(domain,f3(domain),'-.r','LineWidth',3);
axis([-3 5 -50 50]);
box on;
set(gca,'XTick',[],'YTick',[]);
legend([p1,p2,p3],{'L(q_i,\theta)','L(q_j,\theta)','ln(p(x | \theta))'},'Location','NorthWest','FontSize',14);

% Create line
annotation(gcf,'line',[0.4356 0.4356],[0.5976 0.1108],'LineStyle',':');

% Create line
annotation(gcf,'line',[0.3673 0.3673],[0.5146 0.1108],'LineStyle',':');

% Create textbox
annotation(gcf,'textbox',[0.3447 0.02411 0.08859 0.1012],...
  'String',{'\theta^{old}'},...
  'FontSize',16,...
  'FitBoxToText','off',...
  'LineStyle','none');

% Create textbox
annotation(gcf,'textbox',[0.4185 0.02411 0.08859 0.1012],...
  'String',{'\theta^{new}'},...
  'FontSize',16,...
  'FitBoxToText','off',...
  'LineStyle','none');


pdfcrop;
printPmtkFigure emLogLikelihoodMax


end