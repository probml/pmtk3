%DEMGTM2 Demonstrate GTM for visualisation.
%
%	Description
%	 This script demonstrates the use of a GTM with  a two-dimensional
%	latent space to visualise data in a higher dimensional space. This is
%	done through the use of the mean responsibility and magnification
%	factors.
%
%	See also
%	DEMGTM1, GTM, GTMEM, GTMPOST
%

%	Copyright (c) Ian T Nabney (1996-2001)


% Fix seeds for reproducible results
rand('state', 420);
randn('state', 420);

ndata = 300
clc;
disp('This demonstration shows how a Generative Topographic Mapping')
disp('can be used to model and visualise high dimensional data.  The')
disp('data is generated from a mixture of two spherical Gaussians in')
dstring = ['four dimensional space. ', num2str(ndata), ...
      ' data points are generated.'];
disp(dstring);
disp(' ');
disp('Press any key to continue.')
pause
% Create data
data_dim = 4;
latent_dim = 2;
mix = gmm(data_dim, 2, 'spherical');
mix.centres = [1 1 1 1; 0 0 0 0];
mix.priors = [0.5 0.5];
mix.covars = [0.1 0.1];

[data, labels] = gmmsamp(mix, ndata);

latent_shape = [15 15];  % Number of latent points in each dimension
nlatent = prod(latent_shape);  % Number of latent points
num_rbf_centres = 16;

clc;
dstring = ['Next we generate and initialise the GTM.  There are ',...
      num2str(nlatent), ' latent points'];
disp(dstring);
dstring = ['arranged in a square of ', num2str(latent_shape(1)), ...
      ' points on a side.  There are ', num2str(num_rbf_centres), ...
      ' centres in the'];
disp(dstring);
disp('RBF model, which has Gaussian activation functions.')
disp(' ')
disp('Once the model is created, the latent data sample')
disp('and RBF centres are placed uniformly in the square [-1 1 -1 1].')
disp('The output weights of the RBF are computed to map the latent');
disp('space to the two dimensional PCA subspace of the data.');
disp(' ')
disp('Press any key to continue.');
pause;

% Create and initialise GTM model
net = gtm(latent_dim, nlatent, data_dim, num_rbf_centres, ...
   'gaussian', 0.1);

options = foptions;
options(1) = -1;
options(7) = 1;    % Set width factor of RBF
net = gtminit(net, options, data, 'regular', latent_shape, [4 4]);

options = foptions;
options(14) = 30;
options(1) = 1;

clc;
dstring = ['We now train the model with ', num2str(options(14)), ...
      ' iterations of'];
disp(dstring)
disp('the EM algorithm for the GTM.')
disp(' ')
disp('Press any key to continue.')
pause;

[net, options] = gtmem(net, data, options);

disp(' ')
disp('Press any key to continue.')
pause;

clc;
disp('We now visualise the data by plotting, for each data point,');
disp('the posterior mean and mode (in latent space).  These give');
disp('a summary of the entire posterior distribution in latent space.')
disp('The corresponding values are joined by a line to aid the')
disp('interpretation.')
disp(' ')
disp('Press any key to continue.');
pause;
% Plot posterior means
means = gtmlmean(net, data);
modes = gtmlmode(net, data);
PointSize = 12;
ClassSymbol1 = 'r.';
ClassSymbol2 = 'b.';
fh1 = figure;
hold on;
title('Visualisation in latent space')
plot(means((labels==1),1), means(labels==1,2), ...
  ClassSymbol1, 'MarkerSize', PointSize)
plot(means((labels>1),1),means(labels>1,2),...
   ClassSymbol2, 'MarkerSize', PointSize)

ClassSymbol1 = 'ro';
ClassSymbol2 = 'bo';
plot(modes(labels==1,1), modes(labels==1,2), ...
  ClassSymbol1)
plot(modes(labels>1,1),modes(labels>1,2),...
   ClassSymbol2)

% Join up means and modes
for n = 1:ndata
   plot([means(n,1); modes(n,1)], [means(n,2); modes(n,2)], 'g-')
end
% Place legend outside data plot
legend('Mean (class 1)', 'Mean (class 2)', 'Mode (class 1)',...
   'Mode (class 2)', -1);

% Display posterior for a data point
% Choose an interesting one with a large distance between mean and
% mode
[distance, point] = max(sum((means-modes).^2, 2));
resp = gtmpost(net, data(point, :));

disp(' ')
disp('For more detailed information, the full posterior distribution')
disp('(or responsibility) can be plotted in latent space for a')
disp('single data point.  This point has been chosen as the one')
disp('with the largest distance between mean and mode.')
disp(' ')
disp('Press any key to continue.');
pause;

R = reshape(resp, fliplr(latent_shape));
XL = reshape(net.X(:,1), fliplr(latent_shape));
YL = reshape(net.X(:,2), fliplr(latent_shape));

fh2 = figure;
imagesc(net.X(:, 1), net.X(:,2), R);
hold on;
tstr = ['Responsibility for point ', num2str(point)];
title(tstr);
set(gca,'YDir','normal')
colormap(hot);
colorbar
disp(' ');
disp('Press any key to continue.')
pause

clc
disp('Finally, we visualise the data with the posterior means in')
disp('latent space as before, but superimpose the magnification')
disp('factors to highlight the separation between clusters.')
disp(' ')
disp('Note the large magnitude factors down the centre of the')
disp('graph, showing that the manifold is stretched more in')
disp('this region than within each of the two clusters.')
ClassSymbol1 = 'g.';
ClassSymbol2 = 'b.';

fh3 = figure;
mags = gtmmag(net, net.X);
% Reshape into grid form
Mags = reshape(mags, fliplr(latent_shape));
imagesc(net.X(:, 1), net.X(:,2), Mags);
hold on
title('Dataset visualisation with magnification factors')
set(gca,'YDir','normal')
colormap(hot);
colorbar
hold on; % Else the magnification plot disappears
plot(means(labels==1,1), means(labels==1,2), ...
  ClassSymbol1, 'MarkerSize', PointSize)
plot(means(labels>1,1), means(labels>1,2), ...
  ClassSymbol2, 'MarkerSize', PointSize)

disp(' ')
disp('Press any key to exit.')
pause

close(fh1);
close(fh2);
close(fh3);
clear all;