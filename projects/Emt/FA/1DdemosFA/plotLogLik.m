  % plots logLik Vs beta, sigma2, mu, bias for Jaakkola and Bohning bound 
  clear all
  betaT = 1;
  sigma2T = 1;
  muT = 0;
  biasT = 1;

  nr = 2; nc = 2;
  % compute empirical prob of 1 and 0
  mu = muT;
  sigma2 = sigma2T;
  beta = betaT;
  bias = biasT;
  delta = 0.01;
  xvals = [-100:delta:100];
  probEmp(1) = delta*sum(sigmoid(-beta*xvals - bias).*normpdf(xvals, mu, sqrt(sigma2)));
  probEmp(2) = delta*sum(sigmoid(beta*xvals + bias).*normpdf(xvals, mu, sqrt(sigma2)));

  for num = 1:4
    % range of values
    switch num
    case 1
      vals = [0.1:.1:2];
      labelX = 'Loading factor';
    case 2
      vals = [0.1:.1:2];
      labelX = 'Prior Variance';
    case 3
      vals = [-2:.1:2];
      labelX = 'Bias';
    case 4
      vals = [-2:.1:2];
      labelX = 'Prior Mean';
    end

    % plot wrt bias
    for i = 1:length(vals)
      switch num 
      case 1
        bias = biasT;
        beta = vals(i);
        mu = muT;
        sigma2 = sigma2T;
      case 2
        bias = biasT;
        beta = betaT;
        mu = muT;
        sigma2 = vals(i);
      case 3
        bias = vals(i);
        beta = betaT;
        mu = muT;
        sigma2 = sigma2T;
      case 4
        bias = biasT;
        beta = betaT;
        mu = vals(i);
        sigma2 = sigma2T;
      end
      % true p(y=1|theta)
      p1 = delta*sum(sigmoid(beta*xvals + bias).*normpdf(xvals, mu, sqrt(sigma2)));
      probTrue(i,2) = p1;
      % true p(y=1|theta)
      p1 = delta*sum(sigmoid(-beta*xvals - bias).*normpdf(xvals, mu, sqrt(sigma2)));
      probTrue(i,1) = p1;

      % Bohning bound p(y=1)
      for k = 1:2
        psi = 10;
        for iter = 1:20
          [A,b,c] = quadBoundBinary('bohning',psi, bias);
          V = inv(A*beta^2 + 1/sigma2);
          m = V*((b+k-1)*beta + mu/sigma2);
          psi = beta*m + bias;
        end
        probBohning(i,k) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + (k-1)*bias - mu^2/(2*sigma2));
      end
      % Jaakkola bound 
      for k = 1:2
        psi = 10;
        for iter = 1:20
          [A,b,c] = quadBoundBinary('jaakkola',psi, bias);
          V = inv(A*beta^2 + 1/sigma2);
          m = V*((b+k-1)*beta + mu/sigma2);
          psi = sqrt(beta^2*V + (beta*m + bias)^2);
        end
        probJaakkola(i,k) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + (k-1)*bias - mu^2/(2*sigma2));
      end
    end
    logLikTrue = sum(bsxfun(@times, probEmp, log(probTrue)),2);
    logLikBohning = sum(bsxfun(@times, probEmp, log(probBohning)),2);
    logLikJaakkola = sum(bsxfun(@times, probEmp, log(probJaakkola)),2);

    subplot(nr,nc,num)
    h(1) = plot(vals, logLikTrue, 'k', 'linewidth',3);
    hold on
    [v,i] = max(logLikTrue);
    plot(vals(i), v, 'o','color','k', 'markersize',10, 'linewidth',3); 
    h(3) = plot(vals, logLikBohning,'b','linewidth',3);
    [v,i] = max(logLikBohning);
    plot(vals(i), v, 'o','color','b', 'markersize',10, 'linewidth',3); 
    h(2) = plot(vals, logLikJaakkola,'r','linewidth',3);
    [v,i] = max(logLikJaakkola);
    plot(vals(i), v, 'o','color','r', 'markersize',10, 'linewidth',3); 

    %ht = title('Log-Likelihood and Lower Bounds');
    hx = xlabel(labelX);
    if num == 3
      legend(h,'Truth','Jaakkola','Bohning','location','south');
    end
    set(gca,'fontname','Helvetica');
    set(hx,'fontname','avantgarde','fontsize',13,'color',[.3 .3 .3]);
    %set(ht,'fontname','avantgarde','fontsize',13,'fontweight','bold'); 
    set(gca,'box','off','tickdir','out','ticklength',[.02 .02],'xgrid','on','ygrid','on','xcolor',[.3 .3 .3],'ycolor',[.3 .3 .3],'linewidth',1);
  end
  print -dpdf logLikVsParams.pdf


