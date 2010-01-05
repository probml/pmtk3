function net = gpunpak(net, hp)
%GPUNPAK Separates hyperparameter vector into components. 
%
%	Description
%	NET = GPUNPAK(NET, HP) takes an Gaussian Process data structure NET
%	and  a hyperparameter vector HP, and returns a Gaussian Process data
%	structure  identical to the input model, except that the covariance
%	bias BIAS, output noise NOISE, the input weight vector INWEIGHTS and
%	the vector of covariance function specific parameters  FPAR have all
%	been set to the corresponding elements of HP.
%
%	See also
%	GP, GPPAK, GPFWD, GPERR, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'gp');
if ~isempty(errstring);
  error(errstring);
end
if net.nwts ~= length(hp)
  error('Invalid weight vector length');
end

net.bias = hp(1);
net.noise = hp(2);

% Unpack input weights
mark1 = 2 + net.nin;
net.inweights = hp(3:mark1);

% Unpack function specific parameters
net.fpar = hp(mark1 + 1:size(hp, 2));

