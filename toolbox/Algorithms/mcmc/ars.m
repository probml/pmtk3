function samples = ars(func, a, b, domain, nSamples, varargin)
%   ARS - Adaptive Rejection Sampling
%         sample perfectly & efficiently from a univariate log-concave
%         function
%
%   func        a function handle to the log of a log-concave function.
%                  evaluated as: func(x, varargin{:}), where x could  be a
%                  vector
%
%   domain      the domain of func. may be unbounded.
%                  ex: [1,inf], [-inf,inf], [-5, 20]
%
%   a,b         two points on the domain of func, a<b. if domain is bounded
%                  then use a=domain(1), b=domain(2). if domain is
%                  unbounded on the left, the derivative of func for x=<a
%                  must be positive. if domain is unbounded on the right,
%                  the derivative for x>=b must be negative.
%
%                  ex: domain = [1,inf], a=1, b=20 (ensuring that
%                  func'(x>=b)<0
%
%   nSamples    number of samples to draw
%
%   varargin    extra arguments passed directly to func
%
%PMTKauthor   Daniel Eaton
% danieljameseaton@gmail.com
%PMTKdate 2006

debug = 0;

if domain(1)>=domain(2)
	error('invalid domain');
end

if a>=b || isinf(a) || isinf(b) || a<domain(1) || b>domain(2)
	error('invalid a & b');
end

numDerivStep = 1e-3;
S = [a a+numDerivStep b-numDerivStep b];

if domain(1)==-inf
	% ensure the derivative there is positive
	f = func(S(1:2), varargin{:});
	if (f(2)-f(1))<=0
		error('derivative at a must be positive, since the domain is unbounded to the left');
	end
end

if domain(2)==inf
	% ensure the derivative there is negative
	f = func(S(3:4), varargin{:});
	if (f(2)-f(1))>=0
		error('derivative at b must be negative, since the domain is unbounded to the right');
	end
end

% initialize a mesh on which to create upper & lower hulls
nInitialMeshPoints = 3;
S = unique([S(1) S(2):(S(3)-S(2))/(nInitialMeshPoints+1):S(3) S(4)]);
fS = func(S, varargin{:});

[lowerHull upperHull] = arsComputeHulls(S, fS, domain);

nSamplesNow = 0;
iterationNo = 1;
while 1

	if debug
		figure(1); clf;
		arsPlot(upperHull, lowerHull, domain, S, fS, func, varargin{:});
		pause;
	end

	% sample x from Hull
	x = arsSampleUpperHull( upperHull );

	[lhVal uhVal] = arsEvalHulls( x, lowerHull, upperHull );

	U = rand;

	meshChanged = 0; % flag to indicate if a new point has been added to the mesh

	% three cases for acception/rejection
	if U<=lhVal/uhVal,
		% accept, u is below lower bound
		nSamplesNow = nSamplesNow + 1;
		samples(nSamplesNow) = x;

	elseif U<=func(x, varargin{:})/uhVal
		% accept, u is between lower bound and f
		nSamplesNow = nSamplesNow + 1;
		samples(nSamplesNow) = x;

		meshChanged = 1;
	else
		% reject, u is between f and upper bound
		meshChanged = 1;

	end

	if meshChanged == 1
		S = sort( [S x] );
		fS = func(S, varargin{:});

		[lowerHull upperHull] = arsComputeHulls(S, fS, domain);
	end

	if debug
		fprintf('iteration %i, samples collected %i\n', iterationNo, nSamplesNow);
		pause;
	end

	iterationNo = iterationNo + 1;

	if nSamplesNow==nSamples
		break;
	end

end

function [lowerHull upperHull] = arsComputeHulls(S, fS, domain)

% compute lower piecewise-linear hull
% if the domain of func is unbounded to the left or right, then the lower
% hull takes on -inf to the left or right of the end points of S

for li=1:length(S)-1
	lowerHull(li).m = (fS(li+1)-fS(li))/(S(li+1)-S(li));
	lowerHull(li).b = fS(li) - lowerHull(li).m*S(li);
	lowerHull(li).left = S(li);
	lowerHull(li).right = S(li+1);
end

% compute upper piecewise-linear hull

upperHull = [];

if isinf(domain(1))
	% first line (from -infinity)
	m = (fS(2)-fS(1))/(S(2)-S(1));
	b = fS(1) - m*S(1);
	pr = exp(b)/m * ( exp(m*S(1)) - 0 ); % integrating in from -infinity
	upperHull(1).m = m;
	upperHull(1).b = b;
	upperHull(1).pr = pr;
	upperHull(1).left = -inf;
	upperHull(1).right = S(1);
end

% second line
m = (fS(3)-fS(2))/(S(3)-S(2));
b = fS(2) - m*S(2);
pr = exp(b)/m * ( exp(m*S(2)) - exp(m*S(1)) );
i = length(upperHull)+1;
upperHull(i).m = m;
upperHull(i).b = b;
upperHull(i).pr = pr;
upperHull(i).left = S(1);
upperHull(i).right = S(2);

% interior lines
% there are two lines between each abscissa
for li=2:length(S)-2

	m1 = (fS(li)-fS(li-1))/(S(li)-S(li-1));
	b1 = fS(li) - m1*S(li);

	m2 = (fS(li+2)-fS(li+1))/(S(li+2)-S(li+1));
	b2 = fS(li+1) - m2*S(li+1);

	ix = (b1-b2)/(m2-m1); % compute the two lines' intersection

	pr1 = exp(b1)/m1 * ( exp(m1*ix) - exp(m1*S(li)) );
	i = length(upperHull)+1;
	upperHull(i).m = m1;
	upperHull(i).b = b1;
	upperHull(i).pr = pr1;
	upperHull(i).left = S(li);
	upperHull(i).right = ix;

	i2 = (li-1)*2+1;
	pr2 = exp(b2)/m2 * ( exp(m2*S(li+1)) - exp(m2*ix) );
	i = length(upperHull)+1;
	upperHull(i).m = m2;
	upperHull(i).b = b2;
	upperHull(i).pr = pr2;
	upperHull(i).left = ix;
	upperHull(i).right = S(li+1);

end

% second last line
m = (fS(end-1)-fS(end-2))/(S(end-1)-S(end-2));
b = fS(end-1) - m*S(end-1);
pr = exp(b)/m * ( exp(m*S(end)) - exp(m*S(end-1)) );
i = length(upperHull)+1;
upperHull(i).m = m;
upperHull(i).b = b;
upperHull(i).pr = pr;
upperHull(i).left = S(end-1);
upperHull(i).right = S(end);

if isinf(domain(2))
	% last line (to infinity)
	m = (fS(end)-fS(end-1))/(S(end)-S(end-1));
	b = fS(end) - m*S(end);
	pr = exp(b)/m * ( 0 - exp(m*S(end)) );
	i = length(upperHull)+1;
	upperHull(i).m = m;
	upperHull(i).b = b;
	upperHull(i).pr = pr;
	upperHull(i).left = S(end);
	upperHull(i).right = inf;
end

Z = sum([upperHull(:).pr]);
for li=1:length(upperHull)
	upperHull(li).pr = upperHull(li).pr / Z;
end

function x = arsSampleUpperHull( upperHull )

cdf = cumsum([upperHull.pr]);

% randomly choose a line segment
U = rand;
for li = 1:length(upperHull)
	if( U<cdf(li) ) break;
	end
end

% sample along that line segment
U = rand;

m = upperHull(li).m;
b = upperHull(li).b;
left = upperHull(li).left;
right = upperHull(li).right;

x = log( U*(exp(m*right) - exp(m*left)) + exp(m*left) ) / m;

if isinf(x) || isnan(x)
	error('sampled an infinite or NaN x');
end


function [lhVal uhVal] = arsEvalHulls( x, lowerHull, upperHull )

% lower bound
if x<min([lowerHull.left])
	lhVal = -inf;
elseif x>max([lowerHull.right]);
	lhVal = -inf;
else
	for li=1:length(lowerHull)
		left = lowerHull(li).left;
		right = lowerHull(li).right;

		if x>=left && x<=right
			lhVal = lowerHull(li).m*x + lowerHull(li).b;
			break;
		end
	end
end

% upper bound
for li = 1:length(upperHull)
	left = upperHull(li).left;
	right = upperHull(li).right;

	if x>=left && x<=right
		uhVal = upperHull(li).m*x + upperHull(li).b;
		break;
	end
end

function arsPlot(upperHull, lowerHull, domain, S, fS, func, varargin)


Swidth = S(end)-S(1);
plotStep = Swidth/1000;
ext = 0.15*Swidth; % plot this much before a and past b, if the domain is infinite

left = S(1); right = S(end);
if isinf(domain(1)), left = left - ext; end
if isinf(domain(2)), right = right + ext; end

x = left:plotStep:right;
fx = func(x, varargin{:});

plot(x,fx, 'k-'); hold on;
plot(S, fS, 'ko');
title('ARS');

% plot lower hull
for li=1:length(S)-1

	m = lowerHull(li).m;
	b = lowerHull(li).b;

	x = lowerHull(li).left:plotStep:lowerHull(li).right;
	plot( x, m*x+b, 'b-' );

end

% plot upper bound

% first line (from -infinity)
if isinf(domain(1))
	x = (upperHull(1).right-ext):plotStep:upperHull(1).right;
	m = upperHull(1).m;
	b = upperHull(1).b;
	plot( x, x*m+b, 'r-');
end

% middle lines
for li=2:length(upperHull)-1

	x = upperHull(li).left:plotStep:upperHull(li).right;
	m = upperHull(li).m;
	b = upperHull(li).b;
	plot( x, x*m+b, 'r-');

end

% last line (to infinity)
if isinf(domain(2))
	x = upperHull(end).left:plotStep:(upperHull(end).left+ext);
	m = upperHull(end).m;
	b = upperHull(end).b;
	plot( x, x*m+b, 'r-');
end

