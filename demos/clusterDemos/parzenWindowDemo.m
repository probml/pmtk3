function parzenWindowDemo
% Demonstrate a non-parametric (parzen) density estimator in 1D with a 
%Gaussian kernel
%


    setSeed(0); 
    mix = [0.35,0.65];
    sigma = [0.015,0.01];
    mu = [0.25,0.75];
    n = 50;
    
    %The true function, we are trying to recover
    f = @(x)mix(1)*exp(gaussLogpdf(x,mu(1),sigma(1)) + mix(2)*mvnpdf(x,mu(2),sigma(2)));
    
    data = generateData;
    domain = 0:0.001:1;
    %kernel = 'gauss';
    kernel = 'cube';
    switch kernel
      case 'gauss', hvals = [0.005,0.01,0.1];
      case 'cube', hvals = [0.01,0.1,0.5];
    end
    for i=1:numel(hvals)
       hvalstr = num2str(hvals(i)); decloc = strfind(hvalstr, '.'); if(isempty(decloc)), decloc = 0; end;
       setupFig(hvals(i));
       plot(domain,f(domain'),'-g','LineWidth',2.5);
       hold on
       h=plot(data, 0.1*ones(1,n), '.');
       set(h,'markersize',14,'color','k');
       g = kernelize(hvals(i), kernel);
       plot(domain,g(domain'),'-b','LineWidth',2.5);
       printPmtkFigure(sprintf('parzen%sH0p%s',strcat(upper(kernel(1)), kernel(2:end)), hvalstr((decloc+1):end)));
    end
    placeFigures('nrows',3,'ncols',1,'square',false);

    
    function data = generateData
    %Generate data from a mixture of gaussians. 
        pdf1 = @(n)gaussSample(mu(1),sigma(1),n);
        pdf2 = @(n)gaussSample(mu(2),sigma(2),n);
        data = rand(n,1);
        nmix1 = data <= mix(1);
        data(nmix1) = pdf1(sum(nmix1));
        data(~nmix1) = pdf2(sum(~nmix1));
    end
    
    function g = kernelize(h,kernel)   
    %Use one gaussian kernel per data point with smoothing parameter h. 
        g = @(x)0;
        for i=1:n
          switch kernel
            case 'gauss', g = @(x)g(x) + (1/n)*exp(gaussLogpdf(x,data(i),h^2));
            case 'cube', g = @(x)g(x) + (1/n)*unifpdf(x,data(i)-h/2, data(i)+h/2);
          end
        end
    end
   
    function setupFig(h)
        figure; 
        hold on;
        axis([0,1,0,5]);
        set(gca,'XTick',0:0.5:1,'YTick',[0,5],'box','on','FontSize',16);
        title(['h = ',num2str(h)]);
        scrsz = get(0,'ScreenSize');
        left =  20;   right = 20;
        lower = 50;   upper = 125;
        width = scrsz(3)-left-right;
        height = (scrsz(4)-lower-upper)/3;
        set(gcf,'Position',[left,scrsz(4)/2,width, height]);
        pdfcrop;
    end
    

end