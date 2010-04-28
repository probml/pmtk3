function [samples, energies, diagn] = hmc(f, x, options, gradf, varargin)
%HMC	Hybrid Monte Carlo sampling.
%
%	Description
%	SAMPLES = HMC(F, X, OPTIONS, GRADF) uses a  hybrid Monte Carlo
%	algorithm to sample from the distribution P ~ EXP(-F), where F is the
%	first argument to HMC. The Markov chain starts at the point X, and
%	the function GRADF is the gradient of the `energy' function F.
%
%	HMC(F, X, OPTIONS, GRADF, P1, P2, ...) allows additional arguments to
%	be passed to F() and GRADF().
%
%	[SAMPLES, ENERGIES, DIAGN] = HMC(F, X, OPTIONS, GRADF) also returns a
%	log of the energy values (i.e. negative log probabilities) for the
%	samples in ENERGIES and DIAGN, a structure containing diagnostic
%	information (position, momentum and acceptance threshold) for each
%	step of the chain in DIAGN.POS, DIAGN.MOM and DIAGN.ACC respectively.
%	All candidate states (including rejected ones) are stored in
%	DIAGN.POS.
%
%	[SAMPLES, ENERGIES, DIAGN] = HMC(F, X, OPTIONS, GRADF) also returns
%	the ENERGIES (i.e. negative log probabilities) corresponding to the
%	samples.  The DIAGN structure contains three fields:
%
%	POS the position vectors of the dynamic process.
%
%	MOM the momentum vectors of the dynamic process.
%
%	ACC the acceptance thresholds.
%
%	S = HMC('STATE') returns a state structure that contains the state of
%	the two random number generators RAND and RANDN and the momentum of
%	the dynamic process.  These are contained in fields  randstate,
%	randnstate and mom respectively.  The momentum state is only used for
%	a persistent momentum update.
%
%	HMC('STATE', S) resets the state to S.  If S is an integer, then it
%	is passed to RAND and RANDN and the momentum variable is randomised.
%	If S is a structure returned by HMC('STATE') then it resets the
%	generator to exactly the same state.
%
%	The optional parameters in the OPTIONS vector have the following
%	interpretations.
%
%	OPTIONS(1) is set to 1 to display the energy values and rejection
%	threshold at each step of the Markov chain. If the value is 2, then
%	the position vectors at each step are also displayed.
%
%	OPTIONS(5) is set to 1 if momentum persistence is used; default 0,
%	for complete replacement of momentum variables.
%
%	OPTIONS(7) defines the trajectory length (i.e. the number of leap-
%	frog steps at each iteration).  Minimum value 1.
%
%	OPTIONS(9) is set to 1 to check the user defined gradient function.
%
%	OPTIONS(14) is the number of samples retained from the Markov chain;
%	default 100.
%
%	OPTIONS(15) is the number of samples omitted from the start of the
%	chain; default 0.
%
%	OPTIONS(17) defines the momentum used when a persistent update of
%	(leap-frog) momentum is used.  This is bounded to the interval [0,
%	1).
%
%	OPTIONS(18) is the step size used in leap-frogs; default 1/trajectory
%	length.
%
%	See also
%	METROP
%

%	Copyright (c) Ian T Nabney (1996-2001)

% Global variable to store state of momentum variables: set by set_state
% Used to initialise variable if set
global HMC_MOM
if nargin <= 2
  if ~strcmp(f, 'state')
    error('Unknown argument to hmc');
  end
  switch nargin
    case 1
      samples = get_state(f);
      return;
    case 2
      set_state(f, x);
      return;
  end
end

display = options(1);
if (options(5) == 1)
  persistence = 1;
  % Set alpha to lie in [0, 1)
  alpha = max(0, options(17));
  alpha = min(1, alpha);
  salpha = sqrt(1-alpha*alpha);
else
  persistence = 0;
end
L = max(1, options(7)); % At least one step in leap-frogging
if options(14) > 0
  nsamples = options(14);
else
  nsamples = 100;	% Default
end
if options(15) >= 0
  nomit = options(15);
else
  nomit = 0;
end
if options(18) > 0
  step_size = options(18);	% Step size.
else
  step_size = 1/L;		% Default  
end
x = x(:)';		% Force x to be a row vector
nparams = length(x);

% Set up strings for evaluating potential function and its gradient.
f = fcnchk(f, length(varargin));
gradf = fcnchk(gradf, length(varargin));

% Check the gradient evaluation.
if (options(9))
  % Check gradients
  feval('gradchek', x, f, gradf, varargin{:});
end

samples = zeros(nsamples, nparams);	% Matrix of returned samples.
if nargout >= 2
  en_save = 1;
  energies = zeros(nsamples, 1);
else
  en_save = 0;
end
if nargout >= 3
  diagnostics = 1;
  diagn_pos = zeros(nsamples, nparams);
  diagn_mom = zeros(nsamples, nparams);
  diagn_acc = zeros(nsamples, 1);
else
  diagnostics = 0;
end

n = - nomit + 1;
Eold = feval(f, x, varargin{:});	% Evaluate starting energy.
nreject = 0;
if (~persistence | isempty(HMC_MOM))
  p = randn(1, nparams);		% Initialise momenta at random
else
  p = HMC_MOM;				% Initialise momenta from stored state
end
lambda = 1;

% Main loop.
while n <= nsamples

  xold = x;		    % Store starting position.
  pold = p;		    % Store starting momenta
  Hold = Eold + 0.5*(p*p'); % Recalculate Hamiltonian as momenta have changed

  if ~persistence
    % Choose a direction at random
    if (rand < 0.5)
      lambda = -1;
    else
      lambda = 1;
    end
  end
  % Perturb step length.
  epsilon = lambda*step_size*(1.0 + 0.1*randn(1));

  % First half-step of leapfrog.
  p = p - 0.5*epsilon*feval(gradf, x, varargin{:});
  x = x + epsilon*p;
  
  % Full leapfrog steps.
  for m = 1 : L - 1
    p = p - epsilon*feval(gradf, x, varargin{:});
    x = x + epsilon*p;
  end

  % Final half-step of leapfrog.
  p = p - 0.5*epsilon*feval(gradf, x, varargin{:});

  % Now apply Metropolis algorithm.
  Enew = feval(f, x, varargin{:});	% Evaluate new energy.
  p = -p;				% Negate momentum
  Hnew = Enew + 0.5*p*p';		% Evaluate new Hamiltonian.
  a = exp(Hold - Hnew);			% Acceptance threshold.
  if (diagnostics & n > 0)
    diagn_pos(n,:) = x;
    diagn_mom(n,:) = p;
    diagn_acc(n,:) = a;
  end
  if (display > 1)
    fprintf(1, 'New position is\n');
    disp(x);
  end

  if a > rand(1)			% Accept the new state.
    Eold = Enew;			% Update energy
    if (display > 0)
      fprintf(1, 'Finished step %4d  Threshold: %g\n', n, a);
    end
  else					% Reject the new state.
    if n > 0 
      nreject = nreject + 1;
    end
    x = xold;				% Reset position 
    p = pold;   			% Reset momenta
    if (display > 0)
      fprintf(1, '  Sample rejected %4d.  Threshold: %g\n', n, a);
    end
  end
  if n > 0
    samples(n,:) = x;			% Store sample.
    if en_save 
      energies(n) = Eold;		% Store energy.
    end
  end

  % Set momenta for next iteration
  if persistence
    p = -p;
    % Adjust momenta by a small random amount.
    p = alpha.*p + salpha.*randn(1, nparams);
  else
    p = randn(1, nparams);	% Replace all momenta.
  end

  n = n + 1;
end

if (display > 0)
  fprintf(1, '\nFraction of samples rejected:  %g\n', ...
    nreject/(nsamples));
end
if diagnostics
  diagn.pos = diagn_pos;
  diagn.mom = diagn_mom;
  diagn.acc = diagn_acc;
end
% Store final momentum value in global so that it can be retrieved later
HMC_MOM = p;
return
end
% Return complete state of sampler (including momentum)
function state = get_state(f)

global HMC_MOM
state.randstate = rand('state');
state.randnstate = randn('state');
state.mom = HMC_MOM;
return
end
% Set complete state of sampler (including momentum) or just set randn
% and rand with integer argument.
function set_state(f, x)

global HMC_MOM
if isnumeric(x)
  rand('state', x);
  randn('state', x);
  HMC_MOM = [];
else
  if ~isstruct(x)
    error('Second argument to hmc must be number or state structure');
  end
  if (~isfield(x, 'randstate') | ~isfield(x, 'randnstate') ...
      | ~isfield(x, 'mom'))
    error('Second argument to hmc must contain correct fields')
  end
  rand('state', x.randstate);
  randn('state', x.randnstate);
  HMC_MOM = x.mom;
end
return

end