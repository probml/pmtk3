% Demonstrate classification/decision tree on 2d 3class iris data
% From http://www.mathworks.com/products/statistics/demos.html?file=/products/demos/shipping/stats/classdemo.html

requireStatsToolbox


% "Resubstitution error" is the training set error

%{
meas =
    5.1000    3.5000    1.4000    0.2000
    4.9000    3.0000    1.4000    0.2000
    4.7000    3.2000    1.3000    0.2000
    4.6000    3.1000    1.5000    0.2000
    5.0000    3.6000    1.4000    0.2000
    5.4000    3.9000    1.7000    0.4000
    4.6000    3.4000    1.4000    0.3000
    5.0000    3.4000    1.5000    0.2000
    4.4000    2.9000    1.4000    0.2000
    4.9000    3.1000    1.5000    0.1000
    5.4000    3.7000    1.5000    0.2000
    4.8000    3.4000    1.6000    0.2000
    4.8000    3.0000    1.4000    0.1000
    4.3000    3.0000    1.1000    0.1000
    5.8000    4.0000    1.2000    0.2000
    5.7000    4.4000    1.5000    0.4000
    5.4000    3.9000    1.3000    0.4000
    5.1000    3.5000    1.4000    0.3000
    5.7000    3.8000    1.7000    0.3000
    5.1000    3.8000    1.5000    0.3000
    5.4000    3.4000    1.7000    0.2000
    5.1000    3.7000    1.5000    0.4000
    4.6000    3.6000    1.0000    0.2000
    5.1000    3.3000    1.7000    0.5000
    4.8000    3.4000    1.9000    0.2000
    5.0000    3.0000    1.6000    0.2000
    5.0000    3.4000    1.6000    0.4000
    5.2000    3.5000    1.5000    0.2000
    5.2000    3.4000    1.4000    0.2000
    4.7000    3.2000    1.6000    0.2000
    4.8000    3.1000    1.6000    0.2000
    5.4000    3.4000    1.5000    0.4000
    5.2000    4.1000    1.5000    0.1000
    5.5000    4.2000    1.4000    0.2000
    4.9000    3.1000    1.5000    0.2000
    5.0000    3.2000    1.2000    0.2000
    5.5000    3.5000    1.3000    0.2000
    4.9000    3.6000    1.4000    0.1000
    4.4000    3.0000    1.3000    0.2000
    5.1000    3.4000    1.5000    0.2000
    5.0000    3.5000    1.3000    0.3000
    4.5000    2.3000    1.3000    0.3000
    4.4000    3.2000    1.3000    0.2000
    5.0000    3.5000    1.6000    0.6000
    5.1000    3.8000    1.9000    0.4000
    4.8000    3.0000    1.4000    0.3000
    5.1000    3.8000    1.6000    0.2000
    4.6000    3.2000    1.4000    0.2000
    5.3000    3.7000    1.5000    0.2000
    5.0000    3.3000    1.4000    0.2000
    7.0000    3.2000    4.7000    1.4000
    6.4000    3.2000    4.5000    1.5000
    6.9000    3.1000    4.9000    1.5000
    5.5000    2.3000    4.0000    1.3000
    6.5000    2.8000    4.6000    1.5000
    5.7000    2.8000    4.5000    1.3000
    6.3000    3.3000    4.7000    1.6000
    4.9000    2.4000    3.3000    1.0000
    6.6000    2.9000    4.6000    1.3000
    5.2000    2.7000    3.9000    1.4000
    5.0000    2.0000    3.5000    1.0000
    5.9000    3.0000    4.2000    1.5000
    6.0000    2.2000    4.0000    1.0000
    6.1000    2.9000    4.7000    1.4000
    5.6000    2.9000    3.6000    1.3000
    6.7000    3.1000    4.4000    1.4000
    5.6000    3.0000    4.5000    1.5000
    5.8000    2.7000    4.1000    1.0000
    6.2000    2.2000    4.5000    1.5000
    5.6000    2.5000    3.9000    1.1000
    5.9000    3.2000    4.8000    1.8000
    6.1000    2.8000    4.0000    1.3000
    6.3000    2.5000    4.9000    1.5000
    6.1000    2.8000    4.7000    1.2000
    6.4000    2.9000    4.3000    1.3000
    6.6000    3.0000    4.4000    1.4000
    6.8000    2.8000    4.8000    1.4000
    6.7000    3.0000    5.0000    1.7000
    6.0000    2.9000    4.5000    1.5000
    5.7000    2.6000    3.5000    1.0000
    5.5000    2.4000    3.8000    1.1000
    5.5000    2.4000    3.7000    1.0000
    5.8000    2.7000    3.9000    1.2000
    6.0000    2.7000    5.1000    1.6000
    5.4000    3.0000    4.5000    1.5000
    6.0000    3.4000    4.5000    1.6000
    6.7000    3.1000    4.7000    1.5000
    6.3000    2.3000    4.4000    1.3000
    5.6000    3.0000    4.1000    1.3000
    5.5000    2.5000    4.0000    1.3000
    5.5000    2.6000    4.4000    1.2000
    6.1000    3.0000    4.6000    1.4000
    5.8000    2.6000    4.0000    1.2000
    5.0000    2.3000    3.3000    1.0000
    5.6000    2.7000    4.2000    1.3000
    5.7000    3.0000    4.2000    1.2000
    5.7000    2.9000    4.2000    1.3000
    6.2000    2.9000    4.3000    1.3000
    5.1000    2.5000    3.0000    1.1000
    5.7000    2.8000    4.1000    1.3000
    6.3000    3.3000    6.0000    2.5000
    5.8000    2.7000    5.1000    1.9000
    7.1000    3.0000    5.9000    2.1000
    6.3000    2.9000    5.6000    1.8000
    6.5000    3.0000    5.8000    2.2000
    7.6000    3.0000    6.6000    2.1000
    4.9000    2.5000    4.5000    1.7000
    7.3000    2.9000    6.3000    1.8000
    6.7000    2.5000    5.8000    1.8000
    7.2000    3.6000    6.1000    2.5000
    6.5000    3.2000    5.1000    2.0000
    6.4000    2.7000    5.3000    1.9000
    6.8000    3.0000    5.5000    2.1000
    5.7000    2.5000    5.0000    2.0000
    5.8000    2.8000    5.1000    2.4000
    6.4000    3.2000    5.3000    2.3000
    6.5000    3.0000    5.5000    1.8000
    7.7000    3.8000    6.7000    2.2000
    7.7000    2.6000    6.9000    2.3000
    6.0000    2.2000    5.0000    1.5000
    6.9000    3.2000    5.7000    2.3000
    5.6000    2.8000    4.9000    2.0000
    7.7000    2.8000    6.7000    2.0000
    6.3000    2.7000    4.9000    1.8000
    6.7000    3.3000    5.7000    2.1000
    7.2000    3.2000    6.0000    1.8000
    6.2000    2.8000    4.8000    1.8000
    6.1000    3.0000    4.9000    1.8000
    6.4000    2.8000    5.6000    2.1000
    7.2000    3.0000    5.8000    1.6000
    7.4000    2.8000    6.1000    1.9000
    7.9000    3.8000    6.4000    2.0000
    6.4000    2.8000    5.6000    2.2000
    6.3000    2.8000    5.1000    1.5000
    6.1000    2.6000    5.6000    1.4000
    7.7000    3.0000    6.1000    2.3000
    6.3000    3.4000    5.6000    2.4000
    6.4000    3.1000    5.5000    1.8000
    6.0000    3.0000    4.8000    1.8000
    6.9000    3.1000    5.4000    2.1000
    6.7000    3.1000    5.6000    2.4000
    6.9000    3.1000    5.1000    2.3000
    5.8000    2.7000    5.1000    1.9000
    6.8000    3.2000    5.9000    2.3000
    6.7000    3.3000    5.7000    2.5000
    6.7000    3.0000    5.2000    2.3000
    6.3000    2.5000    5.0000    1.9000
    6.5000    3.0000    5.2000    2.0000
    6.2000    3.4000    5.4000    2.3000
    5.9000    3.0000    5.1000    1.8000

species =
  150×1 cell array
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'setosa'    }
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'versicolor'}
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }
    {'virginica' }

%}

load fisheriris
N = size(meas,1);
 figure
gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
xlabel('Sepal length');
ylabel('Sepal width');
printPmtkFigure('dtreeIrisData')

s = RandStream('mt19937ar','seed',0);
RandStream.setDefaultStream(s);
cp = cvpartition(species,'k',10);

% fit tree
t = classregtree(meas(:,1:2), species,'names',{'SL' 'SW' });

% plot decision boundary
figure
[x,y] = meshgrid(4:.1:8,2:.1:4.5);
x = x(:);
y = y(:);
[grpname,node] = t.eval([x y]);
gscatter(x,y,grpname,'grb','sod')
title('unpruned decision tree')
printPmtkFigure('dtreeDboundaryUnpruned')

% plot tree
view(t)
%printPmtkFigure('dtreeTreeUnpruned')

% Error rate
dtclass = t.eval(meas(:,1:2));
bad = ~strcmp(dtclass,species);
dtResubErr = sum(bad) / N

dtClassFun = @(xtrain,ytrain,xtest)(eval(classregtree(xtrain,ytrain),xtest));
dtCVErr  = crossval('mcr',meas(:,1:2),species, ...
          'predfun', dtClassFun,'partition',cp)

% Plot misclassified data
figure;
gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
xlabel('Sepal length');
ylabel('Sepal width');
hold on;
plot(meas(bad,1), meas(bad,2), 'kx', 'markersize', 10, 'linewidth', 2);
title(sprintf('Unpruned, train error %5.3f, cv error %5.3f', dtResubErr, dtCVErr))
printPmtkFigure('dtreeDataUnpruned')

% Error rate vs depth
figure;
resubcost = test(t,'resub');
[cost,secost,ntermnodes,bestlevel] = test(t,'cross',meas(:,1:2),species);
plot(ntermnodes,cost,'b-', ntermnodes,resubcost,'r--','linewidth',3)
figure(gcf);
xlabel('Number of terminal nodes');
ylabel('Cost (misclassification error)')
[mincost,minloc] = min(cost);
cutoff = mincost + secost(minloc);
hold on
plot([0 20], [cutoff cutoff], 'k:', 'linewidth', 3)
plot(ntermnodes(bestlevel+1), cost(bestlevel+1), 'mo', 'markersize', 12, 'linewidth', 2)
legend('Cross-validation','Training set','Min + 1 std. err.','Best choice')
printPmtkFigure('dtreeErrorVsDepth')



% prune
pt = prune(t,bestlevel);

% Error rates
dtResubErr = resubcost(bestlevel+1)
dtCVErr  = cost(bestlevel+1)
dtclass = pt.eval(meas(:,1:2));
bad = ~strcmp(dtclass,species);
dtResubErr2 = sum(bad) / N

        
% plot pruned tree
view(pt)
%printPmtkFigure('dtreeTreePruned')

% plot new decision boundary
figure
[grpname,node] = pt.eval([x y]);
gscatter(x,y,grpname,'grb','sod')
title('pruned decision tree')
printPmtkFigure('dtreeDboundaryPruned')

% Plot misclassified data
figure;
gscatter(meas(:,1), meas(:,2), species,'rgb','osd');
xlabel('Sepal length');
ylabel('Sepal width');
hold on;
plot(meas(bad,1), meas(bad,2), 'kx', 'markersize', 10, 'linewidth', 2);
title(sprintf('Pruned, train error %5.3f, cv error %5.3f', dtResubErr, dtCVErr))
printPmtkFigure('dtreeDataPruned')
