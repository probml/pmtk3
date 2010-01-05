%DEMSOM1 Demonstrate SOM for visualisation.
%
%	Description
%	 This script demonstrates the use of a SOM with  a two-dimensional
%	grid to map onto data in  two-dimensional space.  Both on-line and
%	batch training algorithms are shown.
%
%	See also
%	SOM, SOMPAK, SOMTRAIN
%

%	Copyright (c) Ian T Nabney (1996-2001)


randn('state', 42);
rand('state', 42);
nin = 2; 
ndata = 300;
% Give data an offset so that network has something to learn.
x = rand(ndata, nin) + ones(ndata, 1)*[1.5 1.5];

clc;
disp('This demonstration of the SOM, or Kohonen network, shows how the')
disp('network units after training lie in regions of high data density.')
disp('First we show the data, which is generated uniformly from a square.')
disp('Red crosses denote the data and black dots are the initial locations')
disp('of the SOM units.')
disp(' ')
disp('Press any key to continue.')
pause
net = som(nin, [8, 7]);
c1 = sompak(net);
h1 = figure;
plot(x(:, 1), x(:, 2), 'r+');
hold on
plot(c1(:,1), c1(:, 2), 'k.');
drawnow;  % Force figure to be drawn before training starts
options = foptions;

% Ordering phase
options(1) = 1;
options(14) = 50;
%options(14) = 5; % Just for testing
options(18) = 0.9;  % Initial learning rate
options(16) = 0.05; % Final learning rate
options(17) = 8;    % Initial neighbourhood size
options(15) = 1;    % Final neighbourhood size

disp('The SOM network is trained in two phases using an on-line algorithm.')
disp('Initially the neighbourhood is set to 8 and is then reduced')
disp('linearly to 1 over the first 50 iterations.')
disp('Each iteration consists of a pass through the complete')
disp('dataset, while the weights are adjusted after each pattern.')
disp('The learning rate is reduced linearly from 0.9 to 0.05.')
disp('This ordering phase puts the units in a rough grid shape.')
disp('Blue circles denote the units at the end of this phase.')
disp(' ')
disp('Press any key to continue.')
pause
net2 = somtrain(net, options, x);
c2 = sompak(net2);
plot(c2(:, 1), c2(:, 2), 'bo');
drawnow;

% Convergence phase
options(1) = 1;
options(14) = 400;
options(18) = 0.05;
options(16) = 0.01;
options(17) = 0;
options(15) = 0;

disp('The second, convergence, phase of learning just updates the winning node.')
disp('The learning rate is reduced from 0.05 to 0.01 over 400 iterations.')
disp('Note how the error value does not decrease monotonically; it is')
disp('difficult to decide when training is complete in a principled way.')
disp('The units are plotted as green stars.')
disp(' ')
disp('Press any key to continue.')
pause
net3 = somtrain(net2, options, x);
c3 = sompak(net3);
plot(c3(:, 1), c3(:, 2), 'g*');
drawnow;

% Now try batch training
options(1) = 1;
options(6) = 1;
options(14) = 50;
options(17) = 3;
options(15) = 0;
disp('An alternative approach to the on-line algorithm is a batch update')
disp('rule.  Each unit is updated to be the average weights')
disp('in a neighbourhood (which reduces from 3 to 0) over 50 iterations.');
disp('Note how the error is even more unstable at first, though eventually')
disp('it does converge.')
disp('The final units are shown as black triangles.')
disp(' ')
disp('Press any key to continue.')
pause
net4 = somtrain(net, options, x);
c4 = sompak(net4);
plot(c4(:, 1), c4(:, 2), 'k^')
legend('Data', 'Initial weights', 'Weights after ordering', ...
    'Weights after convergence', 'Batch weights', 2);
drawnow;

disp(' ')
disp('Press any key to end.')
disp(' ')
pause

close(h1);