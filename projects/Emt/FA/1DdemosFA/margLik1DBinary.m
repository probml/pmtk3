  clear all
  mu = 0;
  sigma2 = 1;
  % for numerical integration
  delta = 0.01; 
  xvals = [-100:delta:100]; 
  nr = 2; nc = 2;
  % plot wrt beta
  vals1 = [.1:.5:10];
  vals2 = [-10:.5:10];
  for i = 1:length(vals1)
  i
  for j = 1:length(vals2)
    beta = vals1(i);
    bias = vals2(j);
    % true p(y=1|theta)
    p1 = delta*sum(sigmoid(beta*xvals + bias).*normpdf(xvals, mu, sqrt(sigma2)));
    probTrue(i,j) = p1;
    % Bohning bound p(y=1)
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('bohning',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+1)*beta + mu/sigma2);
      psi = beta*m + bias;
    end
    probBohning(i,j) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));
    % Jaakkola bound 
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('jaakkola',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+1)*beta + mu/sigma2);
      psi = sqrt(beta^2*V + (beta*m + bias)^2);
    end
    probJaakkola(i,j) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));
  end
  end
  break

  figure
  subplot(nr,nc,1)
  h(1) = plot(vals,probTrue,'k','linewidth',3);
  hold on
  h(2) = plot(vals,probJaakkola,'r','linewidth',3);
  h(3) = plot(vals,probBohning,'b','linewidth',3);
  xlabel('Loading factor W');
  ylabel('p(y=1|W,\mu)');
  title('Marginal Probability Vs. W');

  % plot wrt bias 
  vals = [-20:.5:20];
  for i = 1:length(vals)
    beta = 1;
    bias = vals(i);
    % true p(y=1|theta)
    p1 = delta*sum(sigmoid(beta*xvals + bias).*normpdf(xvals, mu, sqrt(sigma2)));
    probTrue(i) = p1;
    % Bohning bound
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('bohning',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+1)*beta + mu/sigma2);
      psi = beta*m + bias;
    end
    probBohning(i) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));
    % Jaakkola bound 
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('jaakkola',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+1)*beta + mu/sigma2);
      psi = sqrt(beta^2*V + (beta*m + bias)^2);
    end
    probJaakkola(i) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + bias - mu^2/(2*sigma2));
  end
  subplot(nr,nc,2)
  h(1) = plot(vals,probTrue,'k','linewidth',3);
  hold on
  h(2) = plot(vals,probJaakkola,'r','linewidth',3);
  h(3) = plot(vals,probBohning,'b','linewidth',3);
  ylim([0 1.05]);
  xlabel('Offset \mu');
  ylabel('p(y=1|W,\mu)');
  title('Marginal Probability Vs. \mu');
  legend(h,'Truth','Jaakkola','Bohning','location','southeast');

  clear all
  mu = 0;
  sigma2 = 1;
  % for numerical integration
  delta = 0.01; 
  xvals = [-100:delta:100]; 
  nr = 2; nc = 2;
  % plot wrt beta
  vals = [.1:.5:10];
  for i = 1:length(vals)
    bias = 1;
    beta = vals(i);
    % true p(y=1|theta)
    p1 = delta*sum(sigmoid(-beta*xvals - bias).*normpdf(xvals, mu, sqrt(sigma2)));
    probTrue(i) = p1;
    % Bohning bound p(y=1)
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('bohning',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+0)*beta + mu/sigma2);
      psi = beta*m + bias;
    end
    probBohning(i) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + 0*bias - mu^2/(2*sigma2));
    % Jaakkola bound 
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('jaakkola',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+0)*beta + mu/sigma2);
      psi = sqrt(beta^2*V + (beta*m + bias)^2);
    end
    probJaakkola(i) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + 0*bias - mu^2/(2*sigma2));
  end

  subplot(nr,nc,3)
  h(1) = plot(vals,probTrue,'k','linewidth',3);
  hold on
  h(2) = plot(vals,probJaakkola,'r','linewidth',3);
  h(3) = plot(vals,probBohning,'b','linewidth',3);
  xlabel('Loading factor W');
  ylabel('p(y=0|W,\mu)');
  title('Marginal Probability Vs. W');

  % plot wrt bias 
  vals = [-20:.5:20];
  for i = 1:length(vals)
    beta = 1;
    bias = vals(i);
    % true p(y=1|theta)
    p1 = delta*sum(sigmoid(-beta*xvals - bias).*normpdf(xvals, mu, sqrt(sigma2)));
    probTrue(i) = p1;
    % Bohning bound
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('bohning',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+0)*beta + mu/sigma2);
      psi = beta*m + bias;
    end
    probBohning(i) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + 0*bias - mu^2/(2*sigma2));
    % Jaakkola bound 
    psi = 10;
    for iter = 1:20
      [A,b,c] = quadBoundBinary('jaakkola',psi, bias);
      V = inv(A*beta^2 + 1/sigma2);
      m = V*((b+0)*beta + mu/sigma2);
      psi = sqrt(beta^2*V + (beta*m + bias)^2);
    end
    probJaakkola(i) = sqrt(V)*inv(sqrt(sigma2))*exp(m^2/(2*V) - c + 0*bias - mu^2/(2*sigma2));
  end
  subplot(nr,nc,4)
  h(1) = plot(vals,probTrue,'k','linewidth',3);
  hold on
  h(2) = plot(vals,probJaakkola,'r','linewidth',3);
  h(3) = plot(vals,probBohning,'b','linewidth',3);
  ylim([0 1.05]);
  xlabel('Offset \mu');
  ylabel('p(y=0|W,\mu)');
  title('Marginal Probability Vs. \mu');




