function demhint(nin, nhidden, nout)
%DEMHINT Demonstration of Hinton diagram for 2-layer feed-forward network.
%
%	Description
%
%	DEMHINT plots a Hinton diagram for a 2-layer feedforward network with
%	5 inputs, 4 hidden units and 3 outputs. The weight vector is chosen
%	from a Gaussian distribution as described under MLP.
%
%	DEMHINT(NIN, NHIDDEN, NOUT) allows the user to specify the number of
%	inputs, hidden units and outputs.
%
%	See also
%	HINTON, HINTMAT, MLP, MLPPAK, MLPUNPAK
%

%	Copyright (c) Ian T Nabney (1996-2001)

if nargin < 1 nin = 5; end
if nargin < 2 nhidden = 7; end
if nargin < 3 nout = 3; end

% Fix the seed for reproducible results
randn('state', 42);
clc
disp('This demonstration illustrates the plotting of Hinton diagrams')
disp('for Multi-Layer Perceptron networks.')
disp(' ')
disp('Press any key to continue.')
pause
net = mlp(nin, nhidden, nout, 'linear');

[h1, h2] = mlphint(net);
clc
disp('The MLP has been created with')
disp(['    ' int2str(nin) ' inputs'])
disp(['    ' int2str(nhidden) ' hidden units'])
disp(['    ' int2str(nout) ' outputs'])
disp(' ')
disp('One figure is produced for each layer of weights.')
disp('For each layer the fan-in weights are arranged in rows for each unit.')
disp('The bias weight is separated from the rest by a red vertical line.')
disp('The area of each box is proportional to the weight value: positive')
disp('values are white, and negative are black.')
disp(' ')
disp('Press any key to exit.'); 
pause; 
delete(h1);
delete(h2);
