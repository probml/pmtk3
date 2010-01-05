function hp = gppak(net)
%GPPAK	Combines GP hyperparameters into one vector.
%
%	Description
%	HP = GPPAK(NET) takes a Gaussian Process data structure NET and
%	combines the hyperparameters into a single row vector HP.
%
%	See also
%	GP, GPUNPAK, GPFWD, GPERR, GPGRAD
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Check arguments for consistency
errstring = consist(net, 'gp');
if ~isempty(errstring);
  error(errstring);
end
hp = [net.bias, net.noise, net.inweights, net.fpar];
