function posteriorInference()
  colorB = [0 0 1];
  colorJ = [1 0 0];
  colorT = [0 0 0];

  mu = 0;
  sigma2 = 1;
  colors = getColorsRGB();
  nr = 2; nc = 2;
  % LIKELIHOOD 
  if 1
    % lower bound to logLik
    beta = 1; bias = 1;
    x = [-20:.1:10];
    [py, px, postx, pyBohning, postxBohning, probBohning, pyJaakkola, postxJaakkola, probJaakkola] = varApprox(x, beta, bias, mu, sigma2);
    % plot
    figure(1);
    clf
    subplot(nr,nc,1)
    %subplot(221);
    h(1) = plot(x,py,'color',colorT,'linewidth',3);
    hold on;
    h(4) = fill(x,px,'g','edgecolor','g');
    h(2) = plot(x,pyJaakkola,'color',colorJ,'linewidth',3);
    h(3) = plot(x,pyBohning,'color',colorB,'linewidth',3);
    set(gca,'xgrid','on');
    ylim([0 1.1])
    xlim([-5 5])
    hx = xlabel('z')
    hy = ylabel('Likelihood Lower Bound');
    ht = title('W= 1, \mu = 1');
    set(gca,'fontname','Helvetica');
    set([hx hy],'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out','xtick',[-4 0 +4],'ytick',[0 0.5 1],'ticklength',[.02 .02],'xgrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);

    subplot(nr,nc,3)
    h(3) = plot(x,postxBohning,'color',colorB,'linewidth',3);
    hold on
    h(2) = plot(x,postxJaakkola,'color',colorJ,'linewidth',3);
    h(1) = plot(x,postx,'color',colorT,'linewidth',3);
    set(gca,'xgrid','on');
    ylim([0 0.5])
    xlim([-5 5])
    hy = ylabel('Posterior distribution');
    hx = xlabel('z')
    set(gca,'fontname','Helvetica');
    set([hx hy],'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(gca,'box','off','tickdir','out','xtick',[-4 0 +4],'ytick',[0 0.5 1],'ticklength',[.02 .02],'xgrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);

    %print -dpdf fig21.pdf

    beta = 5;
    bias = 1;
    figure(1);
    x = [-20:.1:10];
    [py, px, postx, pyBohning, postxBohning, probBohning, pyJaakkola, postxJaakkola, probJaakkola] = varApprox(x, beta, bias, mu, sigma2);
    subplot(nr,nc,2)
    h(4) = fill(x,px,'g','edgecolor','g');
    hold on
    h(1) = plot(x,py,'color',colorT,'linewidth',3);
    h(2) = plot(x,pyJaakkola,'color',colorJ,'linewidth',3);
    h(3) = plot(x,pyBohning,'color',colorB,'linewidth',3);
    ylim([0 1.1])
    hx = xlabel('z')
    set(gca,'xgrid','on');
    xlim([-5 5])
    ylim([0 1.1])
    ht = title('W = 5, \mu = 1');
    legend(h, 'Sigmoid','Jaakkola','Bohning','location','northwest')
    set(gca,'fontname','Helvetica');
    set(hx,'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out','xtick',[-4 0 +4],'ytick',[0 0.5 1],'ticklength',[.02 .02],'xgrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);


    subplot(nr,nc,4)
    h(3) = plot(x,postxBohning,'color',colorB,'linewidth',3);
    hold on
    h(2) = plot(x,postxJaakkola,'color',colorJ,'linewidth',3);
    h(1) = plot(x,postx,'color',colorT,'linewidth',3);
    set(gca,'xgrid','on');
    ylim([0 1.1])
    xlim([-5 5])
    hx = xlabel('z')
    legend(h,'Truth','Jaakkola','Bohning','location','northwest')
    ylim([0 1.1])
    set(gca,'fontname','Helvetica');
    set([hx hy],'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    set(gca,'box','off','tickdir','out','xtick',[-4 0 +4],'ytick',[0 0.5 1],'ticklength',[.02 .02],'xgrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);

    print -dpdf fig2.pdf

    return;
    beta = 1;
    bias = 10;
    x = [-20:.1:20];
    figure(3);
    clf
    [py, px, postx, pyBohning, postxBohning, probBohning, pyJaakkola, postxJaakkola, probJaakkola] = varApprox(x, beta, bias, mu, sigma2);
    subplot(nr,nc,1)
    plot(x,py,'color',colorT,'linewidth',3);
    hold on
    fill(x,px,'g','edgecolor','g');
    plot(x,pyJaakkola,'color',colorJ,'linewidth',3);
    plot(x,pyBohning,'color',colorB,'linewidth',3);
    ylim([0 1.1])
    xlabel('z')
    set(gca,'xgrid','on');
    xlim([-10 10])
    %ylim([0 1.1])
    title('W = 1, \mu = 10');

    subplot(nr,nc,3)
    %subplot(221);
    h(3) = plot(x,postxBohning,'color',colorB,'linewidth',3);
    hold on
    h(2) = plot(x,postxJaakkola,'color',colorJ,'linewidth',3);
    h(1) = plot(x,postx,'color',colorT,'linewidth',3);
    set(gca,'xgrid','on');
    ylim([0 0.5])
    xlim([-20 20])
    xlabel('z')
    %ylim([0 1.1])
    print -dpdf fig23.pdf
  end

function [py, px, postx, pyBohning, postxBohning, probBohning, pyJaakkola, postxJaakkola, probJaakkola] = varApprox(x, beta, bias, mu, sigma2)

    % likelihood
    py = sigmoid(x*beta + bias);
    % prior
    px = normpdf(x, mu, sqrt(sigma2));
    % marginal likelihood using numerical integration
    delta = 0.01;
    xvals = [-100:delta:100];
    margLik = delta*sum(sigmoid(beta*xvals + bias).*normpdf(xvals, mu, sqrt(sigma2)));
    % true posterior
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('bohning',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+1)*beta + mu/sigma2);
      psi = beta*m + bias;
    end
    postx = (py.*px)./margLik;
    % approx posterior Bohning
    postxBohning = normpdf(x, m, sqrt(V));
    bohning = 0.5*A*(beta*x).^2 - b*(beta*x) + c;
    pyBohning = exp(beta*x + bias - bohning);
    probBohning = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));
    % approx posterior Jaakkola 
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('jaakkola',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+1)*beta + mu/sigma2);
      psi = sqrt(beta^2*V + (beta*m + bias)^2);
    end
    postxJaakkola = normpdf(x, m, sqrt(V));
    jaakkola = 0.5*A*(beta*x).^2 - b*beta*x + c;
    pyJaakkola = exp(beta*x + bias - jaakkola);
    probJaakkola = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));



