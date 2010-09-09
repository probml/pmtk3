%% Demonstrate density modelling with a PPCA mixture model
% Slightly modified version of demgmm5 from netlab
%%

% This file is from pmtk3.googlecode.com

function mixPpcaDemoNetlab()


if ~exist('gmm')
   error('must install netlab from http://www.ncrg.aston.ac.uk/netlab/index.php')
end

%data = mkClusterData;
data = mkAnnulusData;


% Fit mixture of K 1d PPCA models
Ks = [1 3 10];
for i=1:length(Ks)
   ncentres = Ks(i);
   ppca_dim = 1;
   
   fh1 = figure;
   plot(data(:, 1), data(:, 2), 'o')
   set(gca, 'Box', 'on')
   axis equal
   hold on
   
   mix = gmm(2, ncentres, 'ppca', ppca_dim);
   options = foptions;
   options(14) = 10;
   options(1) = -1;  % Switch off all warnings
   
   % Just use 10 iterations of k-means in initialisation
   % Initialise the model parameters from the data
   mix = gmminit(mix, data, options);
   options(1)  = 1;		% Prints out error values.
   options(14) = 30;		% Number of iterations.
   [mix, options, errlog] = gmmem(mix, data, options);
   
   
   % Now plot the result
   for i = 1:ncentres
      % Plot the PC vectors
      v = mix.U(:,:,i);
      start=mix.centres(i,:)-sqrt(mix.lambda(i))*(v');
      endpt=mix.centres(i,:)+sqrt(mix.lambda(i))*(v');
      linex = [start(1) endpt(1)];
      liney = [start(2) endpt(2)];
      line(linex, liney, 'Color', 'k', 'LineWidth', 3)
      % Plot ellipses of one standard deviation
      theta = 0:0.02:2*pi;
      x = sqrt(mix.lambda(i))*cos(theta);
      y = sqrt(mix.covars(i))*sin(theta);
      % Rotate ellipse axes
      rot_matrix = [v(1) -v(2); v(2) v(1)];
      ellipse = (rot_matrix*([x; y]))';
      % Adjust centre
      ellipse = ellipse + ones(length(theta), 1)*mix.centres(i,:);
      plot(ellipse(:,1), ellipse(:,2), 'r-')
   end
   
   fname = sprintf('mixPpcaAnnulus%d', ncentres);
   printPmtkFigure(fname)
end

end

function [X] = mkAnnulusData()
n = 500;
r = rand(1,n) + 1;
theta = rand(1,n)*(2*pi);
x1 = r .* sin(theta);
x2 = r .* cos(theta);
X = [x1(:) x2(:)];
end


   function data = mkClusterData()
ndata = 500;
data = randn(ndata, 2);
prior = [0.3 0.5 0.2];
% Mixture model swaps clusters 1 and 3
datap = [0.2 0.5 0.3];
datac = [0 2; 0 0; 2 3.5];
datacov = repmat(eye(2), [1 1 3]);
data1 = data(1:prior(1)*ndata,:);
data2 = data(prior(1)*ndata+1:(prior(2)+prior(1))*ndata, :);
data3 = data((prior(1)+prior(2))*ndata +1:ndata, :);

% First cluster has axis aligned variance and centre (2, 3.5)
data1(:, 1) = data1(:, 1)*0.1 + 2.0;
data1(:, 2) = data1(:, 2)*0.8 + 3.5;
datacov(:, :, 3) = [0.1*0.1 0; 0 0.8*0.8];

% Second cluster has variance axes rotated by 30 degrees and centre (0, 0)
rotn = [cos(pi/6) -sin(pi/6); sin(pi/6) cos(pi/6)];
data2(:,1) = data2(:, 1)*0.2;
data2 = data2*rotn;
datacov(:, :, 2) = rotn' * [0.04 0; 0 1] * rotn;

% Third cluster is at (0,2)
data3(:, 2) = data3(:, 2)*0.1;
data3 = data3 + repmat([0 2], prior(3)*ndata, 1);

% Put the dataset together again
data = [data1; data2; data3];

   end
   
