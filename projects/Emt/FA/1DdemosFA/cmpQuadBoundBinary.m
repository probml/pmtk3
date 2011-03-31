    clear all
    nr = 2; nc = 2;
    colorB = [1 0 0];
    colorJ = [0 0 1];
    colorT = [0 0 0];

    mu = 0;
    sigma2 = 1;
    beta = 1;
    bias = 0;
    x = [-30:.1:40];
    % lse function
    lse = log(1+exp(beta*x + bias));
    sigmoidf = sigmoid(beta*x + bias);
    % bohning bound
    vals = [-5 10];
    for i = 1:length(vals)
      psi = vals(i);
      [A, b, c] = quadBoundBinary('bohning',psi, bias);
      bohning(i,:) = 0.5*A*(beta*x).^2 - b*(beta*x) + c;
    end
    % Jaakkola bound
    vals = [1 10];
    for i = 1:length(vals)
      xi = vals(i);
      [A, b, c] = quadBoundBinary('jaakkola',xi, bias);
      jaakkola(i,:) = 0.5*A*(beta*x).^2 - b*beta*x + c;
    end
    % plot
    figure;
    subplot(nr, nc, 1)
    h(2) = plot(x,bohning(1,:),'color', 0.5*colorB,'linewidth',3);
    hold on
    h(3) = plot(x,bohning(2,:),'color', colorB,'linewidth',3);
    h(1) = plot(x,lse,'color', colorT,'linewidth',3);
    ht = title('Bohning Bound');
    hx = xlabel('\eta');
    legend(h, 'lse','location','southeast')
    ylim([-2 40])
    xlim([-28 40])
    set(gca,'fontname','Helvetica');
    set(hx,'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out','ticklength',[.02 .02],'xgrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);

    subplot(nr, nc, 2)
    h(2)=plot(x, jaakkola(1,:),'color',0.5*colorJ,'linewidth',3);
    hold on
    h(3)=plot(x, jaakkola(2,:),'color',colorJ,'linewidth',3);
    h(1)=plot(x,lse,'color', colorT,'linewidth',3);
    ylim([-2 40])
    xlim([-28 40])
    ht = title('Jaakkola Bound');
    hx = xlabel('\eta');
    legend(h, 'lse','location','southeast')

    set(gca,'fontname','Helvetica');
    set(hx,'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out','ticklength',[.02 .02],'xgrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);




