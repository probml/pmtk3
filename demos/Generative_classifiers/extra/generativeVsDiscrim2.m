%% Generative vs Discriminative classifier illustration

figure();
hold all;
domain = 0:0.001:1;
f1 = @(x)sigmoid(27*x-15);
f2 = @(x) sigmoid(-27*x+15);
linespec = {'LineWidth',3};
plot(domain,f1(domain),'-b',linespec{:});
plot(domain,f2(domain),'-r',linespec{:});
plot([0.556,0.556],[0,1.2],'-g',linespec{:});

set(gca, 'XTick', 0:0.2:1, 'YTick',0:0.2:1.2, ...
    'XLim', [0,1], 'YLim', [0,1.2], 'box','on', 'FontSize', 14);
xlabel('x','FontSize',14);

%p(x|C_1)
annotation(gcf,'textbox',[0.25 0.794 0.096 0.07927],...
    'String',{'p(x|C_1)'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');
%p(x|C_2)
annotation(gcf,'textbox',[0.75 0.794 0.096 0.07927],...
    'String',{'p(x|C_2)'},...
    'FontSize',14,...
    'FitBoxToText','off',...
    'LineStyle','none');






