function [samples, energies, diagn] = metrop(f, x, options, gradf, varargin)
%METROP	Markov Chain Monte Carlo sampling with Metropolis algorithm.
%
%	Description
%	 SAMPLES = METROP(F, X, OPTIONS) uses the Metropolis algorithm to
%	sample from the distribution P ~ EXP(-F), where F is the first
%	argument to METROP.   The Markov chain starts at the point X and each
%	candidate state is picked from a Gaussian proposal distribution and
%	accepted or rejected according to the Metropolis criterion.
%
%	SAMPLES = METROP(F, X, OPTIONS, [], P1, P2, ...) allows additional
%	arguments to be passed to F().  The fourth argument is ignored, but
%	is included for compatibility with HMC and the optimisers.
%
%	[SAMPLES, ENERGIES, DIAGN] = METROP(F, X, OPTIONS) also returns a log
%	of the energy values (i.e. negative log probabilities) for the
%	samples in ENERGIES and DIAGN, a structure containing diagnostic
%	information (position and acceptance threshold) for each step of the
%	chain in DIAGN.POS and DIAGN.ACC respectively.  All candidate states
%	(including rejected ones) are stored in DIAGN.POS.
%
%	S = METROP('STATE') returns a state structure that contains the state
%	of the two random number generators RAND and RANDN. These are
%	contained in fields randstate,  randnstate.
%
%	METROP('STATE', S) resets the state to S.  If S is an integer, then
%	it is passed to RAND and RANDN. If S is a structure returned by
%	METROP('STATE') then it resets the generator to exactly the same
%	state.
%
%	The optional parameters in the OPTIONS vector have the following
%	interpretations.
%
%	OPTIONS(1) is set to 1 to display the energy values and rejection
%	threshold at each step of the Markov chain. If the value is 2, then
%	the position vectors at each step are also displayed.
%
%	OPTIONS(14) is the number of samples retained from the Markov chain;
%	default 100.
%
%	OPTIONS(15) is the number of samples omitted from the start of the
%	chain; default 0.
%
%	OPTIONS(18) is the variance of the proposal distribution; default 1.
%
%	See also
%	HMC
%

%	Copyright (c) Ian T Nabney (1996-2001)

if nargin <= 2
  if ~strcmp(f, 'state')
    error('Unknown argument to metrop');
  end
  switch nargin
    case 1
      % Return state of sampler
      samples = get_state(f);	% Function defined in this module
      return;
    case 2
      % Set the state of the sampler
      set_state(f, x);		% Function defined in this module
      return;
  end
end

if 0
seed = 42;
randn('state', seed);
rand('state', seed)
end

display = options(1);
if options(14) > 0
  nsamples = options(14);
else
  nsamples = 100;
end
if options(15) >= 0
  nomit = options(15);
else
  nomit = 0;
end
if options(18) > 0.0
  std_dev = sqrt(options(18));
else
  std_dev = 1.0;   % default
end			
nparams = length(x);

% Set up string for evaluating potential function.
f = fcnchk(f, length(varargin));

samples = zeros(nsamples, nparams);		% Matrix of returned samples.
if nargout >= 2
  en_save = 1;
  energies = zeros(nsamples, 1);
else
  en_save = 0;
end
if nargout >= 3
  diagnostics = 1;
  diagn_pos = zeros(nsamples, nparams);
  diagn_acc = zeros(nsamples, 1);
else
  diagnostics = 0;
end

% Main loop.
n = - nomit + 1;
Eold = feval(f, x, varargin{:});	% Evaluate starting energy.
nreject = 0;				% Initialise count of rejected states.
while n <= nsamples

  xold = x;
  % Sample a new point from the proposal distribution
  x = xold + randn(1, nparams)*std_dev;
  %fprintf('netlab propose: xold = %5.3f,%5.3f, xnew = %5.3f,%5.3f\n',...
  %	xold(1), xold(2), x(1), x(2));

  % Now apply Metropolis algorithm.
  Enew = feval(f, x, varargin{:});	% Evaluate new energy.
  a = exp(Eold - Enew);			% Acceptance threshold.
  if (diagnostics & n > 0)
    diagn_pos(n,:) = x;
    diagn_acc(n,:) = a;
  end
  if (display > 1)
    fprintf(1, 'New position is\n');
    disp(x);
  end

  r = rand(1);
  %fprintf('netlab: n=%d, a=%f/%f=%5.3f (%5.3f), r=%5.3f\n',...
  %	  n, exp(-Enew), exp(-Eold), a, exp(-Enew)/exp(-Eold), r);
  if a > r	% Accept the new state.
    Eold = Enew;
    if (display > 0)
      fprintf(1, 'Finished step %4d  Threshold: %g\n', n, a);
    end
  else			% Reject the new state
    if n > 0
      nreject = nreject + 1;
    end
    x = xold;	% Reset position 
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
  n = n + 1;
end

if (display > 0)
  fprintf(1, '\nFraction of samples rejected:  %g\n', ...
          nreject/(nsamples));
end

if diagnostics
  diagn.pos = diagn_pos;
  diagn.acc = diagn_acc;
end

% Return complete state of the sampler.
function state = get_state(f)

state.randstate = rand('state');
state.randnstate = randn('state');
return

% Set state of sampler, either from full state, or with an integer
function set_state(f, x)

if isnumeric(x)
  rand('state', x);
  randn('state', x);
else
  if ~isstruct(x)
    error('Second argument to metrop must be number or state structure');
  end
  if (~isfield(x, 'randstate') | ~isfield(x, 'randnstate'))
    error('Second argument to metrop must contain correct fields')
  end
  rand('state', x.randstate);
  randn('state', x.randnstate);
end
return
