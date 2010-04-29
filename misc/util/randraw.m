function varargout = randraw(distribName, distribParams, varargin)
%
%   EFFICIENT RANDOM VARIATES GENERATOR
% 
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/7309
%PMTKauthor Alex Bar-Guy
%
% See alphabetical list of the supported distributions below (over 50 distributions)
% 
% 1)  randraw 
%           presents general help.
% 2)  randraw( distribName ) 
%           presents help for the specific distribution defined 
%           by usage string distribName (see table below).
% 3)  Y = randraw( distribName, distribParams, sampleSize );
%           returns array Y of size = sampleSize of random variates from distribName  
%           distribution with parameters distribParams
%
%               ALPHABETICAL LIST OF THE SUPPORTED DISTRIBUTIONS:
%  ____________________________________________________________________
% |      DISTRIBUTION NAME                    |   USAGE STRING         |
% |___________________________________________|________________________|
% |        Alpha                              |    'alpha'             |
% |        Anglit                             |    'anglit'            |
% |        Antilognormal                      |    'lognorm'           |
% |        Arcsin                             |    'arcsin'            |
% |        Bernoulli                          |    'bern'              |
% |        Bessel                             |    'bessel'            |
% |        Beta                               |    'beta'              |
% |        Binomial                           |    'binom'             |
% |        Bradford                           |    'bradford'          |
% |        Burr                               |    'burr'              |
% |        Cauchy                             |    'cauchy'            |
% |        Chi                                |    'chi'               |
% |        Chi-Square (Non-Central)           |    'chisqnc'           |
% |        Chi-Square (Central)               |    'chisq'             |
% |        Cobb-Douglas                       |    'lognorm'           |
% |        Cosine                             |    'cosine'            |
% |        Double-Exponential                 |    'laplace'           |
% |        Erlang                             |    'erlang'            |
% |        Exponential                        |    'exp'               |
% |        Extreme-Value                      |    'extrval'           |
% |        F (Central)                        |    'f'                 |
% |        F (Non-Central)                    |    'fnc'               |
% |        Fisher-Tippett                     |    'extrval'           |
% |        Fisk                               |    'fisk'              |
% |        Frechet                            |    'frechet'           |
% |        Furry                              |    'furry'             |
% |        Gamma                              |    'gamma'             |
% |        Generalized Inverse Gaussian       |    'gig'               |
% |        Generalized Hyperbolic             |    'gh'                |
% |        Geometric                          |    'geom'              |
% |        Gompertz                           |    'gompertz'          |
% |        Gumbel                             |    'gumbel'            |
% |        Half-Cosine                        |    'hcos'              |
% |        Hyperbolic Secant                  |    'hsec'              |
% |        Hypergeometric                     |    'hypergeom'         |
% |        Inverse Gaussian                   |    'ig'                |
% |        Laplace                            |    'laplace'           |
% |        Logistic                           |    'logistic'          |
% |        Lognormal                          |    'lognorm'           |
% |        Lomax                              |    'lomax'             |
% |        Lorentz                            |    'lorentz'           |
% |        Maxwell                            |    'maxwell'           |
% |        Negative Binomial                  |    'negbinom'          |
% |        Normal                             |    'norm'              |
% |        Normal-Inverse-Gaussian (NIG)      |    'nig'               |
% |        Pareto                             |    'pareto'            |
% |        Pareto2                            |    'pareto2'           |
% |        Pascal                             |    'pascal'            |
% |        Planck                             |    'planck'            |
% |        Poisson                            |    'po'                |
% |        Quadratic                          |    'quadr'             |
% |        Rademacher                         |    'rademacher'        |
% |        Rayleigh                           |    'rayl'              |
% |        Semicircle                         |    'semicirc'          |
% |        Skellam                            |    'skellam'           |
% |        Student's-t                        |    't'                 |
% |        Triangular                         |    'tri'               |
% |        Truncated Normal                   |    'normaltrunc'       |
% |        Tukey-Lambda                       |    'tukeylambda'       |
% |        U-shape                            |    'u'                 |
% |        Uniform (continuous)               |    'uniform'           |
% |        Von Mises                          |    'vonmises'          |
% |        Wald                               |    'wald'              |
% |        Weibull                            |    'weibull'           |
% |        Wigner Semicircle                  |    'wigner'            |
% |        Yule                               |    'yule'              |
% |        Zeta                               |    'zeta'              |
% |        Zipf                               |    'zipf'              |
% |___________________________________________|________________________|

%  Version 1.5 - December 2005
%        'true' and 'false' functions were replased by ones and zeros to support Matlab releases 
%         below 6.5
%  Version 1.4 - September 2005 -
%      Bugs fix:
%        1) GAMMA distribution (thanks to Earl Lawrence):
%             special case for a<1
%        2) GIG distribution (thanks to Panagiotis Braimakis):
%            typo in help 
%            code adjustment to overcome possible computational overflows
%        3) CHI SQUARE distribution
%            typo in help
%  Version 1.3 - July 2005 -
%      Bug fix:
%         Typo in GIG distribution generation:
%         should be 'out' instead of 'x' in lines 1852 and 1858 
%  Version 1.2 - May 2005  -   
%      Bugs fix: 
%        1) Poisson distribution did not work for lambda < 21.4. Typo ( ti instead of t )
%        2) GIG distribution:  support to chi=0 or psi=0 cases
%        3) Beta distribution: column sampleSize 
%        4) Cauchy distribution: typo in example
%        5) Chi distribution:   typo in example
%        6) Non-central F distribution:  number of input parameters
%        7) INVERSE GAUSSIAN (IG) distribution: typo in example
%
%  Version 1.1 - April 2005 -  Bug fix:   Generation from binomial distribution using only 'binomial'
%                                   usage string was changed to 'binom' ( 'binomial' works too ).
%  Version 1.0 - March 2005 -  Initial version
%  Alex Bar Guy  &  Alexander Podgaetsky
%    alex@wavion.co.il

% These programs are distributed in the hope that they will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

% Any comments and suggestions please send to:
%    alex@wavion.co.il

% Reference links:
%   1) http://mathworld.wolfram.com/topics/StatisticalDistributions.html
%   2) http://en.wikipedia.org/wiki/Category:Probability_distributions
%   3) http://www.brighton-webs.co.uk/index.asp
%   4) http://www.jstatsoft.org/v11/i03/v11i03.pdf
%   5) http://www.quantlet.com/mdstat/scripts/csa/html/node236.html

funcName = mfilename;

if nargin == 0
     help(funcName);
     return;
elseif nargin == 1
     runMode = 'distribHelp';
elseif nargin == 2
     runMode = 'genRun';
     sampleSize = [1 1];
else
     runMode = 'genRun';
     sampleSize = [varargin{1:end}];
end

distribNameInner = lower( distribName( ~isspace( distribName ) ) );

if strcmp(runMode, 'distribHelp')
     fid = fopen( [ funcName '.m' ], 'r' );
     printHelpFlag = 0;
     while 1
          tline = fgetl( fid );
          if ~ischar( tline )
               fprintf( '\n Unknown distribution name ''%s''.\n', distribName );
               break;
          end
          if ~isempty( strfind( tline, [ 'END ', distribNameInner,' HELP' ] ) )
               printHelpFlag = 0;
               break;
          end
          if printHelpFlag
               startPosition = strfind( tline, ' % ' ) + 3;
               printLine = tline( startPosition : end );
               if ~strcmp( funcName, 'randraw' )
                    indxs = strfind( printLine, 'randraw' );
                    while ~isempty( indxs )
                         headLine = printLine( 1:indxs(1)-1 );
                         tailLine = printLine( indxs(1)+7:end );
                         printLine = [ headLine, funcName, tailLine ];
                         indxs = strfind( printLine, 'randraw' );
                    end
               end
               pause(0.02);
               fprintf( '\n%s', printLine );
          end
          if ~isempty( strfind( tline, [ 'START ', distribNameInner,' HELP' ] ) )
               printHelpFlag = 1;
          end
     end
     fprintf( '\n\n' );
     fclose( fid );
     return;
end

if length(sampleSize) == 1
     sampleSize = [ sampleSize, 1 ];
end

if strcmp(runMode, 'genRun')
     runExample = 0;
     plotFlag = 0;

     dbclear if warning;
     out = [];
     if prod(sampleSize) > 0
          switch lower( distribNameInner )
               case {'alpha'}
                    % START alpha HELP
                    % THE ALPHA DISTRIBUTION
                    %
                    % pdf(y) = b*normpdf(a-b./y) ./ (y.^2*normcdf(a)); y>0; a>0; b>0;
                    % cdf(y) = normcdf(a-b./y)/normcdf(a); y>0; a>0; b>0;
                    %   where normpdf(x) = 1/sqrt(2*pi) * exp(-1/2*x.^2); is the standard normal PDF
                    %         normcdf(x) = 0.5*(1+erf(y/sqrt(2))); is the standard normal CDF
                    %
                    % PARAMETERS:
                    %   a - shape parameter (a>0)
                    %   b - shape parameter (b>0)
                    %
                    % SUPPORT:
                    %   y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('alpha', [], sampleSize) - generate sampleSize number
                    %         of variates from Alpha distribution with shape parameters a and b;
                    %   randraw('alpha') - help for Alpha distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('alpha', [1 2], [1 1e5]);
                    %  2.   y = randraw('alpha', [2 3], 1, 1e5);
                    %  3.   y = randraw('alpha', [10 50], 1e5 );
                    %  4.   y = randraw('alpha', [20.5 30.5], [1e5 1] );
                    %  5.   randraw('alpha');
                    % END alpha HELP

                    % References:
                    % 1. doc erf

                    checkParamsNum(funcName, 'Alpha', 'alpha', distribParams, [2]);
                    a  = distribParams(1);
                    b  = distribParams(2);
                    validateParam(funcName, 'Alpha', 'alpha', '[a, b]', 'a', a, {'> 0'});
                    validateParam(funcName, 'Alpha', 'alpha', '[a, b]', 'b', b, {'> 0'});

                    out = b ./ ( a - norminv(normcdf(a)*rand(sampleSize)) );

               case {'anglit'}
                    % START anglit HELP
                    % THE ANGLIT DISTRIBUTION
                    %
                    % Standard form of anglit distribution:
                    %   pdf(y) = sin(2*y+pi/2);  -pi/4 <= y <= pi/4;
                    %   cdf(y) = sin(y+pi/4).^2; -pi/4 <= y <= pi/4;
                    %
                    %   Mean = Median = Mode = 0;
                    %   Variance = (pi/4)^2 - 0.5;
                    %
                    % General form of anglit distribution:
                    %   pdf(y) = sin(pi/2*(y-t)/s+pi/2);  t-s <= y <= t+s; s>0
                    %   cdf(y) = sin(pi/4*(y-t)/s+pi/4).^2;  t-s <= y <= t+s; s>0
                    %
                    %   Mean = Median = Mode = t;
                    %   Variance = ???????;
                    %
                    % PARAMETERS:
                    %   t - location
                    %   s -scale; s>0
                    %
                    % SUPPORT:
                    %   y,   -pi/4 <= y <= pi.4   - standard Anglit distribution
                    %    or
                    %   y,   t-s <= y <= t+s  - generalized Anglit distribution
                    %
                    % CLASS:
                    %   Continuous distributions
                    %
                    % USAGE:
                    %   randraw('anglit', [], sampleSize) - generate sampleSize number
                    %         of variates from standard Anglit distribution;
                    %   randraw('anglit', [t, s], sampleSize) - generate sampleSize number
                    %         of variates from generalized Anglit distribution
                    %         with location parameter 't' and scale parameter 's';
                    %   randraw('anglit') - help for Anglit distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('anglit', [], [1 1e5]);
                    %  2.   y = randraw('anglit', [], 1, 1e5);
                    %  3.   y = randraw('anglit', [], 1e5 );
                    %  4.   y = randraw('anglit', [10 3], [1e5 1] );
                    %  5.   randraw('anglit');
                    %
                    % END anglit HELP

                    checkParamsNum(funcName, 'Anglit', 'anglit', distribParams, [0, 2]);
                    if numel(distribParams)==2
                         t  = distribParams(1);
                         s  = distribParams(2);
                         validateParam(funcName, 'Anglit', 'anglit', '[t, s]', 's', s, {'> 0'});
                    else
                         t = 0;
                         s = pi/4;
                    end

                    out = t + s * (4/pi*asin(sqrt(rand(sampleSize)))-1);

               case {'arcsin'}
                    % START arcsin HELP
                    % THE ARC-SINE DISTRIBUTION
                    %
                    % pdf(y) = 1 ./ (pi*sqrt(y.*(1-y))); 0<y<1;
                    % cdf(y) = 2*asin(sqrt(y))/pi; 0<y<1;
                    %
                    % Mean = 0.5;
                    % Variance = 0.125;
                    %
                    % PARAMETERS:
                    %  None
                    %
                    % SUPPORT:
                    %  y,    0<y<1
                    %
                    % CLASS:
                    %   Continuous symmetric distributions
                    % NOTES:
                    %  The arc-sine distribution is a special case of the beta distribution
                    %  with both parameters equal to 1/2. The generalized arc-sine distribution
                    %  is the special case of the beta distribution where the two parameters sum
                    %  to 1 but are not necessarily equal to 1/2.
                    %
                    % USAGE:
                    %   randraw('arcsin', [], sampleSize) - generate sampleSize number
                    %         of variates from the Arc-sine distribution;
                    %   randraw('arcsin') - help for the Arc-sine distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('arcsin', [], [1 1e5]);
                    %  2.   y = randraw('arcsin', [], 1, 1e5);
                    %  3.   y = randraw('arcsin', [], 1e5 );
                    %  4.   randraw('arcsin');                    
                    %  SEE ALSO:
                    %    U distribution
                    % END arcsin HELP

                    checkParamsNum(funcName, 'Arcsin', 'arcsin', distribParams, 0);
                    out = sin( rand(sampleSize)*pi/2 ).^2;

               case {'bernoulli', 'bern'}
                    % START bernoulli HELP START bern HELP
                    % THE BERNOULLI DISTRIBUTION
                    %
                    % pdf(y) = p.^y .* (1-p).^(1-y);
                    % cdf(y) = (y==0)*(1-p) + (y==1)*1;
                    %
                    % PARAMETERS:
                    %    p is a probability of success; (0<p<1)
                    %
                    % SUPPORT:
                    %     y = [0 1];
                    %
                    % CLASS:
                    %   Discrete distributions
                    %
                    % USAGE:
                    %   randraw('bern', p, sampleSize) - generate sampleSize number
                    %         of variates from the Bernoulli distribution with probability of success p
                    %   randraw('bern') - help for the Bernoulli distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('bern', 0.5, [1 1e5]);
                    %  2.   y = randraw('bern', 0.1, 1, 1e5);
                    %  3.   y = randraw('bern', 0.9, 1e5 );
                    %  4.   randraw('bern');                     
                    % END bernoulli HELP END bern HELP

                    checkParamsNum(funcName, 'Bernoulli', 'bernoulli', distribParams, 1);
                    validateParam(funcName, 'Bernoulli', 'bernoulli', 'p', 'p', distribParams(1), {'>=0','<=1'});

                    out = double( rand(  sampleSize  ) < distribParams );

               case {'beta', 'powerfunction', 'powerfunc'}
                    % START beta HELP
                    %  THE BETA DISTRIBUTION
                    % 
                    %  ( sometimes: Power Function distribution )
                    %
                    % Standard form of the Beta distribution:
                    %  pdf(y) = y.^(a-1).*(1-y).^(b-1) / beta(a, b);
                    %  cdf(y) = betainc(y,a,b), if (y>=0 & y<=1); 0, if x<0; 1, if x>1
                    %
                    %  Mean = a/(a+b);
                    %  Variance = (a*b)/((a+b)^2*(a+b+1));
                    %
                    % General form of the Beta distribution:
                    %  pdf(y) = (y-m).^(a-1).*(n-y).^(b-1) / (beta(a, b)*(n-m)^(a+b-1));
                    %  cdf(y) = betainc((y-m)/(n-m),a,b), if (y>=m & y<=n); 0, if x<m; 1, if x>n
                    %
                    %  Mean = (n*a + m*b)/(a+b);
                    %  Variance = (a*b)*(n-m)^2/((a+b)^2*(a+b+1));
                    %
                    % PARAMETERS:
                    %   a>0 - shape parameter
                    %   b>0 - shape parameter
                    %   m - location
                    %   n -scale (upper bound); n>=m
                    %
                    % SUPPORT:
                    %   y,   0<=y<=1 - standard beta distribution
                    %    or
                    %   y,   m<=y<=n - generalized beta distribution
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('beta', [a, b], sampleSize) - generate sampleSize number
                    %         of variates from standard beta distribution with shape parameters
                    %         'a' and 'b'
                    %   randraw('beta', [m, n, a, b], sampleSize) - generate sampleSize number
                    %         of variates from generalized beta distribution on the interval [m, n]
                    %         with shape parameters 'a' and 'b';
                    %   randraw('beta') - help for the Beta distribution;
                    % EXAMPLES:
                    %  1.   y = randraw('beta', [0.2 0.9], [1 1e5]);
                    %  2.   y = randraw('beta', [0.6 3.2], 1, 1e5);
                    %  3.   y = randraw('beta', [-10 20 3.1 6.2], 1e5 );
                    %  4.   y = randraw('beta', [3 4 5.3 0.7], [1e5 1] );
                    %  5.   randraw('beta');                    
                    % END beta HELP

                    % Refernce:
                    %      Dagpunar, John.
                    %      Principles of Random Variate Generation.
                    %      Oxford University Press, 1988.
                    %
                    %  max_ab < 0.5            Joehnk's algorithm
                    %  1 < min_ab              Cheng's algortihm BB
                    %  min_ab <= 1 <= max_ab   Atkinson's switching algorithm
                    %  0.5<= max_ab < 1        Atkinson's switching
                    %  algorithm


                    checkParamsNum(funcName, 'Beta', 'beta', distribParams, [2, 4]);

                    if numel(distribParams) == 2
                         a = distribParams(1);
                         b = distribParams(2);
                         m = 0;
                         n = 1;
                         validateParam(funcName, 'Beta', 'beta', '[a, b]', 'a', a, {'> 0'});
                         validateParam(funcName, 'Beta', 'beta', '[a, b]', 'b', b, {'> 0'});
                    else
                         m = distribParams(1);
                         n = distribParams(2);
                         a = distribParams(3);
                         b = distribParams(4);
                         validateParam(funcName, 'Beta', 'beta', '[m, n, a, b]', 'n-m', n-m, {'>= 0'});
                         validateParam(funcName, 'Beta', 'beta', '[m, n, a, b]', 'a', a, {'> 0'});
                         validateParam(funcName, 'Beta', 'beta', '[m, n, a, b]', 'b', b, {'> 0'});

                    end

                    sampleSizeIn = sampleSize;
                    sampleSize = [ 1, prod( sampleSizeIn ) ];
                    
                    max_ab = max( a, b );
                    min_ab = min( a, b );
                    if max_ab < 0.5
                         %  Use log(u1^a) and log(u2^b), rather than a and b, to avoid
                         %  underflow for very small a or b.

                         loga = log(rand( sampleSize ))/a;
                         logb = log(rand( sampleSize ))/b;
                         logsum = (loga>logb).*(loga + log(1+ exp(logb-loga))) + ...
                              (loga<=logb).*(logb + log(1+ exp(loga-logb)));
                         out = exp(loga - logsum);

                         indxs = find( logsum > 0);

                         while ~isempty( indxs )
                              indxsSize = size( indxs );
                              loga = log(rand( indxsSize ))/a;
                              logb = log(rand( indxsSize ))/b;
                              logsum = (loga>logb).*(loga + log(1+ exp(logb-loga))) + ...
                                   (loga<=logb).*(logb + log(1+ exp(loga-logb)));

                              l = (logsum <= 0);
                              out( indxs( l ) ) = exp(loga(l) - logsum(l));
                              indxs = indxs( ~l );
                         end

                    elseif min_ab > 1
                         % Algorithm BB

                         sum_ab = a + b;
                         lambda = sqrt((sum_ab-2)/(2*a*b-sum_ab));
                         c = min_ab+1/lambda;

                         u1 = rand( sampleSize );
                         u2 = rand( sampleSize );
                         v = lambda*log(u1./(1-u1));
                         z = u1.*u1.*u2;
                         clear('u1'); clear('u2');
                         w = min_ab*exp(v);
                         r = c*v-1.38629436112;
                         clear('v');
                         s = min_ab+r-w;
                         if a == min_ab
                              out = w./(max_ab+w);
                         else
                              out = max_ab./(max_ab+w);
                         end

                         t = log(z);
                         indxs = find( (s+2.609438 < 5*z) & (r+sum_ab*log(sum_ab./(max_ab+w)) < t) );

                         clear('v');
                         clear('z');
                         clear('w');
                         clear('r');
                         while ~isempty( indxs )
                              indxsSize = size( indxs );

                              u1 = rand( indxsSize );
                              u2 = rand( indxsSize );
                              v = lambda*log(u1./(1-u1));
                              z = u1.*u1.*u2;
                              clear('u1'); clear('u2');
                              w = min_ab*exp(v);
                              r = c*v-1.38629436112;
                              clear('v');
                              s = min_ab+r-w;
                              t = log(z);

                              l = (s+2.609438 >= 5*z) | (r+sum_ab*log(sum_ab./(max_ab+w)) >= t);
                              if a == min_ab
                                   out( indxs( l ) ) = w(l)./(max_ab+w(l));
                              else
                                   out( indxs( l ) ) = max_ab./(max_ab+w(l));
                              end
                              indxs = indxs( ~l );

                         end

                    elseif min_ab < 1 & max_ab > 1
                         %  Atkinson's switching method

                         t = (1-min_ab)/(1+max_ab - min_ab);
                         r = max_ab*t/(max_ab*t + min_ab*(1-t)^max_ab);

                         u1 = rand( sampleSize );
                         w = zeros( sampleSize );
                         l = u1 < r;
                         w( l ) =  t*(u1( l )/r).^(1/min_ab);
                         l = ~l;
                         w( l ) =  1- (1-t)*((1-u1(l))/(1-r)).^(1/max_ab);
                         if a == min_ab
                              out = w;
                         else
                              out = 1 - w;
                         end
                         u2 = rand( sampleSize );

                         indxs1 = find(u1 < r);
                         indxs2 = find(u1 >= r);
                         clear('u1');
                         indxs = [ indxs1( log(u2(indxs1)) >= (max_ab-1)*log(1-w(indxs1)) ), ...
                              indxs2( log(u2(indxs2)) >= (min_ab-1)*log(w(indxs2)/t) ) ];

                         clear('u1');
                         clear('u2');
                         while ~isempty( indxs )
                              indxsSize = size( indxs );
                              u1 = rand( indxsSize );
                              w  = zeros( indxsSize );
                              l = u1 < r;
                              w( l ) =  t*(u1( l )/r).^(1/min_ab);
                              l = ~l;
                              w( l ) =  1- (1-t)*((1-u1(l))/(1-r)).^(1/max_ab);

                              u2 = rand( indxsSize );

                              indxs1 = find(u1 < r);
                              indxs2 = find(u1 >= r);
                              clear('u1');
                              l = logical( zeros( indxsSize ) );
                              l( [ indxs1( log(u2(indxs1)) < (max_ab-1)*log(1-w(indxs1)) ), ...
                                   indxs2( log(u2(indxs2)) < (min_ab-1)*log(w(indxs2)/t) ) ] ) = 1;

                              clear('u1');
                              clear('u2');
                              if a == min_ab
                                   out( indxs(l) ) = w(l);
                              else
                                   out( indxs(l) ) = 1 - w(l);
                              end
                              indxs = indxs( ~l );
                         end

                    else
                         % Atkinson's Algorithm

                         if min_ab == 1
                              t = 0.5;
                              r = 0.5;
                         else
                              t = 1/(1+sqrt(max_ab*(1-max_ab)/(min_ab*(1-min_ab))));
                              r = max_ab*t / (max_ab*t + min_ab*(1-t));
                         end

                         u1 = rand( sampleSize );
                         out = zeros( sampleSize );
                         w  = zeros( sampleSize );
                         l1 = u1 < r;
                         w(l1) = t*(u1(l1)/r).^(1/min_ab);
                         l2 = u1 >= r;
                         w(l2) = 1 - (1-t)*((1-u1(l2))/(1-r)).^(1/max_ab);
                         if a == min_ab
                              out = w;
                         else
                              out = 1 - w;
                         end

                         u2 = rand( sampleSize );
                         indxs1 = find(l1);
                         indxs2 = find(l2);
                         indxs = [ indxs1( log(u2(l1)) >= (max_ab -1)*log((1-w(l1))/(1-t)) ), ...
                              indxs2( log(u2(l2)) >= (min_ab -1) * log(w(l2)/t) ) ];
                         clear('u2');

                         while ~isempty( indxs )
                              indxsSize = size( indxs );
                              u1 = rand( indxsSize );
                              w  = zeros( indxsSize );

                              l1 = u1 < r;
                              w(l1) = t*(u1(l1)/r).^(1/min_ab);
                              l2 = u1 >= r;
                              w(l2) = 1 - (1-t)*((1-u1(l2))/(1-r)).^(1/max_ab);

                              u2 = rand( indxsSize );

                              indxs1 = find(l1);
                              indxs2 = find(l2);
                              clear('u1');
                              l = logical( zeros( indxsSize ) );

                              l( [ indxs1(log(u2(l1)) < (max_ab -1)*log((1-w(l1))/(1-t))), ...
                                   indxs2(log(u2(l2))< (min_ab -1) * log(w(l2)/t)) ] ) = 1;

                              if a == min_ab
                                   out(indxs(l)) = w(l);
                              else
                                   out(indxs(l)) = 1 - w(l);
                              end
                              indxs = indxs( ~l );
                         end

                    end

                    out = m + (n-m) * out;
                    
                    reshape( out, sampleSizeIn );
                    
               case {'bessel'}
                    % START bessel HELP
                    %  THE BESSEL DISTRIBUTION
                    %
                    %  Bessel distribution arises in the theory of stochastic processes.
                    %  Bessel(nu,a) is a discrete distribution on the non-negative integers with
                    %  parameters nu > -1 and a > 0.
                    %
                    % pdf(y) = (a/2).^(2*y+nu) ./ (besseli(nu,a).*factorial(y).*gamma(y+nu+1));
                    %
                    % PARAMETERS: 
                    %   nu > -1, a > 0
                    % SUPPORT:     
                    %   y = 0, 1, 2, 3, ...
                    % CLASS:
                    %   Discrete distributions
                    %
                    % USAGE:
                    %   randraw('bessel', [nu, a], sampleSize) - generate sampleSize number
                    %         of variates from the Bessel distribution with parameters
                    %         'nu' and 'a'
                    %   randraw('bessel') - help for the Bessel distribution;
                    % EXAMPLES:
                    %  1.   y = randraw('bessel', [2 0.9], [1 1e5]);
                    %  2.   y = randraw('bessel', [0.6 3.2], 1, 1e5);
                    %  3.   y = randraw('bessel', [-0.2 8.1], 1e5 );
                    %  4.   y = randraw('bessel', [4 5.3], [1e5 1] );
                    %  5.   randraw('bessel');                      
                    % END bessel HELP
                    
                    % Method:
                    %
                    % We implemented Condensed Table-Lookup method suggested in
                    %    George Marsaglia, "Fast Generation Of Discrete Random Variables,"
                    %    Journal of Statistical Software, July 2004, Volume 11, Issue 4
                    %
                    % Reference:
                    % L. Devroye, "Simulating Bessel random variables,"
                    %  Statistics and Probability Letters, vol. 57, pp. 249-257, 2002.
                    %

                    checkParamsNum(funcName, 'Bessel', 'bessel', distribParams, [2]);
                    
                    nu = distribParams(1);
                    a = distribParams(2);
                    
                    validateParam(funcName, 'Bessel', 'bessel', '[nu, a]', 'nu', nu, {'> -1'});
                    validateParam(funcName, 'Bessel', 'bessel', '[nu, a]', 'a', a, {'> 0'});
                    
                    % mu = 0.5*a*besseli(nu+1,a)/besseli(nu,a);
                    % chi2 = mu + 0.25*a^2*besseli(nu+1,a)/besseli(nu,a)*...
                    %     (besseli(nu+2,a)/besseli(nu+1,a)-besseli(nu+1,a)/besseli(nu,a));

                    besseliNuA =  besseli(nu, a);

                    proceed = 1;
                    if ~isfinite( besseliNuA )
                         warnStr{1} = [upper(funcName), ' - Bessel Variates Generation: '];
                         warnStr{2} = ['besseli(', num2str(nu), ', ' num2str(a), ') returns Inf.'];
                         warnStr{3} = ['Unable to proceed, return zeros ...'];
                         warning('%s\n  %s\n  %s',warnStr{1},warnStr{2},warnStr{3});

                         %warning([upper(funcName), ' - Bessel Variates Generation: besseli(', num2str(nu), ', ' num2str(a), ') returns Inf. Unable to proceed, return zeros ...']);
                         out = zeros( sampleSize );
                         proceed = 0;
                    end
                    if besseliNuA == 0
                         warnStr{1} = [upper(funcName), ' - Bessel Variates Generation: '];
                         warnStr{2} = ['besseli(', num2str(nu), ', ' num2str(a), ') returns 0.'];
                         warnStr{3} = ['Unable to proceed, return zeros ...'];
                         warning('%s\n  %s\n  %s',warnStr{1},warnStr{2},warnStr{3});
                         %warning([upper(funcName), '- Bessel Variates Generation: besseli(', num2str(nu), ', ' num2str(a), ') returns 0. Unable to proceed, return zeros ...']);
                         out = zeros( sampleSize );
                         proceed = 0;
                    end

                    if proceed
                         p0 = exp( nu*log(a/2) - gammaln(nu+1) ) / besseliNuA;
                         if p0 >= 5e-10
                              t = p0;

                              aa = (a/2)^2;
                              nu1 = nu+1;
                              i = 1;
                              while t*2147483648 > 1
                                   t = t * aa/((i)*(i+nu));
                                   i = i + 1;
                              end
                              sizeP = i-1;
                              offset = 0;

                              P = round( 2^30*p0*cumprod([1, aa./((1:sizeP-1).*((1:sizeP-1)+nu))] ) );

                         else % if p0 >= 5e-10
                              m = floor(0.5*(sqrt(a^2+nu^2)-nu));
                              pm = exp( (2*m+nu)*log(a/2) - log(besseliNuA) - ...
                                   gammaln(m+1) - gammaln(m+nu+1) );

                              aa = (a/2)^2;
                              t = pm;
                              i = m + 1;
                              while t * 2147483648 > 1
                                   t = t * aa/((i)*(i+nu));
                                   i = i + 1;
                              end
                              last = i-2;

                              t = pm;
                              j = -1;
                              for i = m-1:-1:0
                                   t = t * (i+1)*(i+1+nu)/aa;
                                   if t*2147483648 < 1
                                        j=i;
                                        break;
                                   end
                              end

                              offset = j+1;
                              sizeP = last-offset+1;

                              P = zeros(1, sizeP);
                              P(m-offset+1:last-offset+1) = ...
                                   round( 2^30*pm*cumprod([1, aa./(((m+1):last).*(((m+1):last)+nu))] ) );
                              P(m-offset:-1:1) = ...
                                   round( 2^30*pm*cumprod((m:-1:(offset+1)).*((m:-1:(offset+1))+nu)/aa) );

                         end % if p0 >= 5e-10, else ...


                         out = randFrom5Tbls( P, offset, sampleSize);
                         
                    end % if proceed

               case {'binom', 'binomial'}
                    % START binom HELP START binomial HELP
                    % THE BINOMIAL DISTRIBUTION
                    %
                    % pdf(y) = nchoosek(n,y)*p^y*(1-p)^(n-y) = ...
                    %          exp( gammaln(n+1) - gammaln(n-y+1) - gammaln(y+1) + ...
                    %               y*log(p) + (n-y)*log(1-p) );  0<p<1, n>1
                    %
                    %  Mean = n*p;
                    %  Variance = n*p*(1-p);
                    %  Mode = floor( (n+1)*p );
                    %
                    % PARAMETERS:
                    %   p  - probability of success in a single trial; (0<p<1)
                    %   n  - total number of trials; (n= 1, 2, 3, 4, ...)
                    %
                    % SUPPORT:
                    %   y - number of success,  y = 0, 1, 2, 3 ...
                    %
                    % CLASS:
                    %   Discrete distributions
                    %
                    % NOTES:
                    %   Constructive definition:
                    %    We consider a random experiment with n independent trials; in each trial
                    %    a certain random event A can occur (the urn model with replacement is
                    %    a special case of such an experiment). Let

                    %      p  = probability of A in a single trial;
                    %      n  = total number of trials;
                    %      y  = number of successes (= number of trials where A occurs).
                    %   
                    % USAGE:
                    %   randraw('binom', [n, p], sampleSize) - generate sampleSize number
                    %         of variates from the Binomial distribution with total number of trials
                    %         'n' and probability of success in a single trial 'p'
                    %   randraw('binom') - help for the Binomial distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('binom', [10 0.9], [1 1e5]);
                    %  2.   y = randraw('binom', [100 0.15], 1, 1e5);
                    %  3.   y = randraw('binom', [5 0.5], 1e5 );
                    %  4.   y = randraw('binom', [1000 0.02], [1e5 1] );
                    %  5.   randraw('binom');                          
                    % END binom HELP END binomial HELP
                    
                    % Method:
                    %
                    % We implemented Condensed Table-Lookup method suggested in
                    %    George Marsaglia, "Fast Generation Of Discrete Random Variables,"
                    %    Journal of Statistical Software, July 2004, Volume 11, Issue 4
                    
                    checkParamsNum(funcName, 'Binomial', 'binomial', distribParams, [2]);
                    
                    n = distribParams(1);
                    p = distribParams(2);
                    
                    validateParam(funcName, 'Binomial', 'binomial', '[n, p]', 'n', n, {'> 0','==integer'});
                    validateParam(funcName, 'Binomial', 'binomial', '[n, p]', 'p', p, {'> 0','< 1'});
                    
                    % if n large and p near 1, generate j=Binom(n,1-p), return n-j

                    switchFlag = 0;
                    if n*p <= 1
                         p = 1-p;
                         switchFlag = 1;
                    end

                    if n*p > 1e3 & n > 1e3

                         out = round( n*p + sqrt(n*p*(1-p))*randn( sampleSize ) );

                    elseif p<1e-4 & n*p > 1 & n*p < 100

                         out = feval(funcName,'poisson',n*p, sampleSize);

                    else

                         mode = floor( (n+1)*p );
                         q = 1 - p;
                         h = p/q;

                         pmode = exp( gammaln(n+1) - gammaln(n-mode+1) - gammaln(mode+1) + ...
                              mode*log(p) + (n-mode)*log(1-p) );
                         
                         i = mode + 1;
                         t = pmode;
                         while t*2147483648 > 1
                              t = t * h*(n-i+1)/i;
                              i = i + 1;
                         end
                         last = i - 2;

                         t = pmode;
                         j = -1;
                         for i=mode-1:-1:0
                              t = t * (i+1)/h/(n-i);
                              if t*2147483648 < 1
                                   j=i;
                                   break;
                              end
                         end
                         offset=j+1;
                         sizeP = last-offset+1;

                         P = zeros(1, sizeP);

                         P(mode-offset+1:last-offset+1) = ...
                              round( 2^30*pmode*cumprod([1, h*(n-(mode+1:last)+1)./(mode+1:last)] ) );
                         P(mode-offset:-1:1) = ...
                              round( 2^30*pmode*cumprod( (mode:-1:offset+1)./(h*(n-(mode-1:-1:offset)))) );

                         out = randFrom5Tbls( P, offset, sampleSize);

                    end
                    if switchFlag
                         out = n - out;
                    end

               case {'bradford'}
                    % START bradford HELP
                    %  THE BRADFORD DISTRIBUTION 
                    %
                    %  pdf(y) = b ./ ( log(1+b)*(1+b*y) ); 0<y<1
                    %  cdf(y) = log(1+b*x) ./ log(1+b);
                    %
                    %  Mean = (b - log(1+b)) / (b*log(1+b));
                    %  Variance = (b*(log(1+b)-2) + 2*log(1+b)) / (2*b*(log(1+b))^2); 
                    %
                    % PARAMETERS:
                    %    b>-1,b~=0  - shape parameter;
                    %
                    % SUPPORT:
                    %    0<y<1
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('bradford', [b], sampleSize) - generate sampleSize number
                    %         of variates from the Bradford distribution with parameter b;
                    %   randraw('bradford') - help for the Bradford distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('bradford', 1, [1 1e5]);
                    %  2.   y = randraw('bradford', 2.2, 1, 1e5);
                    %  3.   y = randraw('bradford', -0.4, 1e5 );
                    %  4.   y = randraw('bradford', 10, [1e5 1] );
                    %  5.   randraw('bradford');                        
                    % END bradford HELP
                    
                    checkParamsNum(funcName, 'Bradford', 'bradford', distribParams, [1]);                    
                    b = distribParams(1);                    
                    validateParam(funcName, 'Bradford', 'bradford', 'b', 'b', b, {'> -1','~=0'});                    
                    
                    out = ((1+b).^rand( sampleSize ) - 1)/b;
                    
               case {'burr', 'fisk'}
                    % START burr HELP START fisk HELP
                    % THE BURR DISTRIBUTION
                    %  pdf(y) = c*d * y.^(-c-1) .* (1+y.^-c).^(-d-1);    y>0
                    %  cdf(y) = (1 + y.^-c).^(-d);
                    %
                    % Mean = gamma(1-1/c)*gamma(1/c+d)/gamma(d);
                    % Variance = COEF / gamma(d)^2;
                    %    where  COEF = gamma(d)*gamma(1-2/c)*gamma(2/c+d) - gamma(1-1/c)^2*gamma(1/c+d)^2;
                    %
                    % PARAMETERS:
                    %   c - shape parameter (c>0)
                    %   d - shape parameter (d>0)
                    %
                    % SUPPORT:
                    %   y>0
                    % 
                    % NOTES:                    
                    %  The Burr distribution with d = 1, is often called the Fisk or 
                    %  LogLogistic distribution
                    %  The Burr distribution is a generalization of the Fisk distribution
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('burr', [c d], sampleSize) - generate sampleSize number
                    %         of variates from the Burr distribution with shape parameters 
                    %         'c' and 'd';
                    %   randraw('burr') - help for the Burr distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('burr', [1 2], [1 1e5]);
                    %  2.   y = randraw('burr', [2 3], 1, 1e5);
                    %  3.   y = randraw('burr', [1.5 0.2], 1e5 );
                    %  4.   y = randraw('burr', [2 2], [1e5 1] );
                    %  5.   randraw('burr');                        
                    % END burr HELP END fisk HELP
                    
                    
                    checkParamsNum(funcName, 'Burr', 'burr', distribParams, [2]);
                    c = distribParams(1);
                    d = distribParams(2);
                    validateParam(funcName, 'Burr', 'burr', '[c, d]', 'c', c, {'> 0'});
                    validateParam(funcName, 'Burr', 'burr', '[c, d]', 'd', d, {'> 0'});

                    out = ( rand(sampleSize).^(-1/d) - 1).^(-1/c);
                    
               case {'cauchy', 'lorentz', 'caushy'}
                    % START cauchy HELP  START lorentz HELP  START caushy HELP
                    % THE CAUCHY DISTRIBUTION
                    % (sometimes: Lorentz or Breit-Wigner distribution) 
                    %
                    %  The standard form of the Caushy distribution:
                    %     pdf = 1 / ( pi*(1+y.^2) );
                    %     cdf = 0.5 + atan(y)/pi;
                    %
                    %  The general form of the Cauchy distribution:
                    %     pdf = s ./ (pi*(s^2+(y-t).^2));  s>0;
                    %     cdf = 0.5 + atan((y-t)/s)/pi;
                    %
                    % The Cauchy distribution does not have a finite mean or 
                    % standard deviation. 
                    % Like the normal distribution, it is symmetric about its median, 
                    %  but with longer and flatter tails.
                    %
                    % PARAMETERS:
                    %   s>0 - scale parameter;
                    %   t - loacation;
                    %
                    % SUPPORT;
                    %    -Inf < y < Inf
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %    randraw('caushy',[],sampleSize) - generation array of sampleSize
                    %         of variates from standard Cauchy distribution;
                    %    randraw('caushy',[t, s],sampleSize) - generation array of sampleSize
                    %         of variates from general form of Cauchy distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('cauchy', [], [1 1e5]);
                    %  2.   y = randraw('cauchy', [10 1], 1, 1e5);
                    %  3.   y = randraw('cauchy', [-10 1.5], 1e5 );
                    %  4.   y = randraw('cauchy', [5.1 10.3], [1e5 1] );
                    %  5.   randraw('cauchy');                       
                    % END cauchy HELP  END lorentz HELP END caushy HELP
                    
                    checkParamsNum(funcName, 'Cauchy', 'cauchy', distribParams, [0, 2]);
                    
                    if numel(distribParams)==2
                         t = distribParams(1);
                         s = distribParams(2);

                         validateParam(funcName, 'Cauchy', 'cauchy', '[t, s]', 's', s, {'> 0'});
                    else
                         t = 0;
                         s = 1;
                    end

                    out = t + s * tan(pi*( rand( sampleSize ) - 0.5));

               case {'chi'}
                    % START chi HELP
                    % THE CHI DISTRIBUTION
                    %
                    % The standard form of the Chi distribution:
                    %
                    %   pdf(y) = exp(-y.^2/2).*y.^(nu-1) / (2^(nu/2-1)*gamma(nu/2)); nu>0; y>0
                    %   cdf(y) = gammainc(y.^2/2,nu/2);
                    %
                    %   Mean = sqrt(2)*gamma((nu+1)/2)/gamma(nu/2);
                    %   Variance = nu - 2*gamma((nu+1)/2)^2/gamma(nu/2)^2;
                    %
                    % The general form of the Chi distribution:
                    %
                    %   pdf(y) = exp(-((y-a)/b).^2/2).*((y-a)/b).^(nu-1) / (2^(nu/2-1)*b*gamma(nu/2)); nu>0; y>a; b>0
                    %   cdf(y) = gammainc(((y-a)/b).^2/2,nu/2);                    
                    %
                    %   Mean = a + sqrt(2)*b*gamma((nu+1)/2)/gamma(nu/2);
                    %   Variance = b^2 * (nu-2*gamma((nu+1)/2)^2/gamma(nu/2)^2);
                    %
                    % PARAMETERS:
                    %   a - location
                    %   b > 0 - scale
                    %   nu > 0 - shape (also, degrees of freedom)                    
                    %
                    % SUPPORT:
                    %   y,   y>0 - standard Chi distribution
                    %    or
                    %   y,   y>a - generalized Chi distribution
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %  The chi-distribution includes several distributions as special cases. 
                    %  If nu is 1, the chi-distribution reduces to the half-normal distribution.
                    %  If nu is 2, the chi-distribution is a Rayleigh distribution. 
                    %  If nu is 3, the chi-distribution is a Maxwell-Boltzmann distribution. 
                    %  A generalized Rayleigh distribution is a chi-distribution with a scale parameter equal to 1.
                    %
                    % USAGE:
                    %   randraw('chi', nu, sampleSize) - generate sampleSize number
                    %         of variates from the standrad Chi distribution with shape parameter 'nu';
                    %   randraw('chi', [a, b, nu], sampleSize) - generate sampleSize number
                    %         of variates from the generalized Chi distribution with location parameter
                    %         'a', scale parameter 'b' and shape parameter 'nu';                    
                    %   randraw('chi') - help for the Chi distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('chi', [2], [1 1e5]);
                    %  2.   y = randraw('chi', [3, 1, 5], 1, 1e5);
                    %  3.   y = randraw('chi', [-10 1, 1], 1e5 );
                    %  4.   y = randraw('chi', [-2.1  3.5 4], [1e5 1] );
                    %  5.   randraw('chi');                    
                    % END chi HELP
                    
                    checkParamsNum(funcName, 'Chi', 'chi', distribParams, [1, 3]);
                    if numel(distribParams)==3
                         a  = distribParams(1);
                         b  = distribParams(2);
                         nu = distribParams(3);   
                         validateParam(funcName, 'Chi', 'chi', '[a, b, nu]', 'b', b, {'> 0'});
                         validateParam(funcName, 'Chi', 'chi', '[a, b, nu]', 'nu', nu, {'> 0'});
                    else
                         a = 0;
                         b = 1;
                         nu = distribParams(1);
                         validateParam(funcName, 'Chi', 'chi', 'nu', 'nu', nu, {'> 0'});                         
                    end                    

                    out = a + b*sqrt( feval(funcName, 'chisq', [nu], sampleSize) );
                    
               case {'chisquare', 'chisq', 'chi2'}
                    % START chisquare HELP START chisq HELP START chi2 HELP
                    % THE CHI SQUARE DISTRIBUTION (with r degrees of freedom) 
                    %
                    %  pdf(y) = y.^(r/2-1) .* exp(-y/2) / (gamma(r/2)*2^(r/2)); r >=1 (integer); y>0
                    %  cdf(y) = gammainc(y/2, r/2); r >=1 (integer); y>0;
                    %
                    %  Mean = r;
                    %  Variance = 2*r;
                    %  Skewness = 2*sqrt(2/r);
                    %  Kurtosis = 12/r;
                    %
                    % PARAMETERS:  
                    %   r - degrees of freedom ( r = 1, 2, 3, ...)
                    %
                    % SUPPORT:      
                    %   y,   y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %   1. Chi square distribution with r degrees of freedom is sum of r squared i.i.d Normal 
                    %      distributions with zero mean and variance equal to 1;
                    %   2. It is a special case of the gamma distribution where:
                    %       the scale parameter is 2 and the shape parameter has the value r/2;
                    %
                    % USAGE:
                    %   randraw('chisq', r, sampleSize) - generate sampleSize number
                    %         of variates from CHI SQUARE distribution with r degrees of freedom;
                    %   randraw('chisq') - help for CHI SQUARE  distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('chisq', [2], [1 1e5]);
                    %  2.   y = randraw('chisq', [3], 1, 1e5);
                    %  3.   y = randraw('chisq', [4], 1e5 );
                    %  4.   y = randraw('chisq', [5], [1e5 1] );
                    %  5.   randraw('chisq');
                    %
                    % SEE ALSO:
                    %  GAMMA, NON-CENTRAL CHI SQUARE distributions
                    % END chisquare HELP END chisq HELP END chi2 HELP
                    
                    
                    checkParamsNum(funcName, 'Chi Square', 'chisq', distribParams, [1]);  
                    r  = distribParams(1);
                    validateParam(funcName, 'Chi Square', 'chisq', 'r', 'r', r, {'> 0','==integer'});
 
                    if r > 1
                         out = 2*randraw('gamma', 0.5*r, sampleSize);
                    else
                         out = randn(sampleSize).^2;
                    end

               case {'chisqnc','chisqnoncentral', 'chisqnoncentr','chi2noncentral'}
                    % START chisqnc HELP START chisqnoncentral HELP START chisqnoncentr HELP START chi2noncentral HELP 
                    % THE NON-CENTRAL CHI-SQUARE DISTRIBUTION (with non-centrality parameter lambda and
                    %                                          r degrees of freedom)
                    %
                    %  The non-central chi-square distribution with degrees of freedom r and 
                    %  non-centrality parameter lambda is the sum of r independent normal
                    %  distributions with standard deviation 1. 
                    %  The non-centrality parameter is one half the sum of squares of the normal 
                    %  means.
                    %
                    %
                    %  pdf(y) = exp(-(y+lambda)/2).*y.^((r-1)/2)./(2*(lambda*y).^(r/4)) .* ...
                    %            besseli(r/2-1, sqrt(lambda*y)); lambda>=0; r=positive integer;
                    %
                    %   Mean = lambda+r;
                    %   Variance = 2*(2*lambda+r);
                    %   Skewness = 2*sqrt(2)*(3*lambda+r)/(2*lambda+r)^(3/2);
                    %   Kurtosis = 12*(4*lambda+r)/(2*lambda+r)^2;
                    %
                    % PARAMETERS:  
                    %   lambda - non-centrality parameter:  lambda>=0
                    %   r - degrees of freedom ( r = 1, 2, 3, ...)
                    %
                    % SUPPORT:      
                    %   y,   y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('chisqnoncentral', [lambda, r], sampleSize) - generate sampleSize number
                    %         of variates from the NON CENTRAL CHI SQUARE distribution with 
                    %         non-centrality parameter 'lambda ' and 'r' degrees of freedom;
                    %   randraw('chisqnoncentral') - help for the NON CENTRAL CHI-SQUARE  distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('chisqnoncentral', [10 2], [1 1e5]);
                    %  2.   y = randraw('chisqnoncentral', [20 3], 1, 1e5);
                    %  3.   y = randraw('chisqnoncentral', [30 4], 1e5 );
                    %  4.   y = randraw('chisqnoncentral', [40 5], [1e5 1] );
                    %  5.   randraw('chisqnoncentral');
                    %
                    % SEE ALSO:
                    %  CHI SQUARE distribution                    
                    % END chisqnc HELP START END chisqnoncentral HELP END chisqnoncentr HELP END chi2noncentral HELP                    
                    
                    checkParamsNum(funcName, 'Non-Central Chi-Square', 'chisqnoncentral', distribParams, [2]);  
                    lambda = distribParams(1);
                    r = distribParams(2);
                    validateParam(funcName, 'Non-Central Chi-Square', 'chisqnoncentral', 'r', 'r', r, {'> 0','==integer'});
                    
                    normalS = sqrt(lambda) + randn( sampleSize );
                    out = feval(funcName, 'chisq', r-1, sampleSize);
                    out = out + normalS.^2;
                    
               case {'cosine'}
                    % START cosine HELP
                    % THE COSINE DISTRIBUTION
                    %
                    % Standard form of the Cosine distribution:
                    %   pdf(y) = (1+cos(y))/(2*pi);  -pi <= y <= pi;
                    %   cdf(y) = (pi+y+sin(y))/(2*pi); -pi <= y <= pi;
                    %
                    %   Mean = Median = Mode = 0;
                    %   Variance = pi^2/3-2;
                    %
                    % General form of the Cosine distribution:
                    %   pdf(y) = (1+cos(pi*(y-t)/s))/(2*s);  t-s <= y <= t+s; s>0
                    %   cdf(y) = (pi + pi*(y-t)/s + sin(pi*(y-t)/s))/(2*pi); t-s <= y <= t+s; s>0
                    %
                    %   Mean = Median = Mode = t;
                    %   Variance = (pi^2/3-2)*(s/pi)^2;
                    %
                    % PARAMETERS:  
                    %   t - location
                    %   s -scale; s>0
                    %
                    % SUPPORT:      
                    %   y,   -pi <= y <= pi   - standard Cosine distribution
                    %    or
                    %   y,   t-s <= y <= t+s  - generalized Cosine distribution
                    %
                    % CLASS:
                    %   Continuous distributions
                    %
                    % USAGE:
                    %   randraw('cosine', [], sampleSize) - generate sampleSize number
                    %         of variates from the standard Cosine distribution;
                    %   randraw('cosine', [t, s], sampleSize) - generate sampleSize number
                    %         of variates from the generalized Cosine distribution
                    %         with location parameter 't' and scale parameter 's';
                    %   randraw('cosine') - help for the Cosine distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('cosine', [], [1 1e5]);
                    %  2.   y = randraw('cosine', [], 1, 1e5);
                    %  3.   y = randraw('cosine', [], 1e5 );
                    %  4.   y = randraw('cosine', [10 3], [1e5 1] );
                    %  5.   randraw('cosine');
                    % END cosine HELP
                    
                    checkParamsNum(funcName, 'Cosine', 'cosine', distribParams, [0, 2]);  
                    if numel(distribParams)==2
                         t  = distribParams(1);
                         s  = distribParams(2);  
                         validateParam(funcName, 'Cosine', 'cosine', '[t, s]', 's', s, {'> 0'});
                    else
                         t = 0;
                         s = pi;                        
                    end   

                    tol = 1e-9;
                    
                    coeff1 = 1/(2*pi);
                    coeff2 = 1/(2*s);
                    coeff3 = pi/s;
                    
                    
                    u = 0.5 - rand(sampleSize);
                    out = -u*s;
                    outNext = out - (coeff1*sin(coeff3*out) + coeff2*out + u) ./ ...
                         (coeff2*cos(coeff3*out)+coeff2);

                    indxs = find(abs(outNext - out)>tol);
                    outPrev = out(indxs);
                    while ~isempty(indxs)

                         outNext = outPrev - (coeff1*sin(coeff3*outPrev) + coeff2*outPrev + u(indxs)) ./ ...
                              (coeff2*cos(coeff3*outPrev)+coeff2);
                         l = (abs(outNext - outPrev)>tol);
                         out(indxs(~l)) = outNext(~l);
                         outPrev = outNext(l);
                         indxs = indxs(l);
                    end
                     
                    out = t + out;
                    
               case {'erlang'}
                    % START erlang HELP
                    % THE ERLANG DISTRIBUTION
                    %
                    %  pdf = (y/a).^(n-1) .* exp( -y/a ) / (a*gamma(n));
                    %  cdf = gammainc( n, y/sacle );
                    %
                    %   Mean = a*n;
                    %   Variance = a^2*n;
                    %   Skewness = 2/sqrt(n);
                    %   Kurtosis = 6/n;
                    %   Mode = (a<1)*0 + (a>=1)*a*(n-1);
                    %
                    %  PARAMETERS:
                    %    a - scale parameter (a>0)
                    %    n - shape parameter (n = 1, 2, 3, ...)
                    %
                    %  SUPPORT:
                    %    y,  y >= 0
                    %
                    %  CLASS:
                    %    Continuous skewed distributions
                    %
                    %  NOTES:
                    %    The Erlang distribution is a special case of the gamma distribution where 
                    %    the shape parameter is an integer
                    %
                    % USAGE:
                    %   randraw('erlang', [a, n], sampleSize) - generate sampleSize number
                    %         of variates from the Erlang distribution
                    %         with scale parameter 'a' and shape parameter 'n';
                    %   randraw('erlang') - help for the Erlang distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('erlang', [1, 3], [1 1e5]);
                    %  2.   y = randraw('erlang', [0.5, 5], 1, 1e5);
                    %  3.   y = randraw('erlang', [10, 6], 1e5 );
                    %  4.   y = randraw('erlang', [7, 4], [1e5 1] );
                    %  5.   randraw('erlang');     
                    %
                    % SEE ALSO:
                    %   GAMMA distribution
                    % END erlang HELP
                    
                    %
                    % Inverse CDF transformation method.
                    %
                   
                    checkParamsNum(funcName, 'Erlang', 'erlang', distribParams, [2]);
                    a = distribParams(1);
                    n = distribParams(2);                    
                    validateParam(funcName, 'Erlang', 'erlang', '[a, n]', 'a', a, {'> 0'});
                    validateParam(funcName, 'Erlang', 'erlang', '[a, n]', 'n', n, {'> 0', '==integer'});
                    
                    out = feval(funcName, 'gamma', n, sampleSize);
                    out = a * out;
                    
               case {'exp','exponential'}
                    % START exp HELP START exponential HELP
                    % THE EXPONENTIAL DISTRIBUTION
                    %
                    % pdf = lambda * exp( -lambda*y );
                    % cdf = 1 - exp(-lambda*y);
                    %
                    %  Mean = 1/lambda;
                    %  Variance = 1/lambda^2;
                    %  Mode = lambda;
                    %  Median = log(2)/lambda;
                    %  Skewness = 2;
                    %  Kurtosis = 6;
                    %
                    % PARAMETERS:
                    %   lambda - inverse scale or rate (lambda>0)
                    %
                    % SUPPORT:
                    %   y,  y>= 0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %  The discrete version of the Exponential distribution is 
                    %  the Geometric distribution.
                    %
                    % USAGE:
                    %   randraw('exp', lambda, sampleSize) - generate sampleSize number
                    %         of variates from the Exponential distribution
                    %         with parameter 'lambda';
                    %   randraw('exp') - help for the Exponential distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('exp', 1, [1 1e5]);
                    %  2.   y = randraw('exp', 1.5, 1, 1e5);
                    %  3.   y = randraw('exp', 2, 1e5 );
                    %  4.   y = randraw('exp', 3, [1e5 1] );
                    %  5.   randraw('exp');
                    %
                    % SEE ALSO:
                    %   GEOMETRIC, GAMMA, POISSON, WEIBULL distributions
                    % END exp HELP END exponential HELP
                    
                    checkParamsNum(funcName, 'Exponential', 'exp', distribParams, [1]);  
                    lambda  = distribParams(1);
                    validateParam(funcName, 'Exponential', 'exp', 'lambda', 'lambda', lambda, {'> 0'});
                    
                    out = -log( rand( sampleSize ) ) / lambda;
               
               case {'extrval', 'extremevalue', 'extrvalue', 'gumbel'}
                    % START extrval HELP START extremevalue HELP START extrvalue HELP START gumbel HELP
                    % THE EXTREME VALUE DISTRIBUTION
                    %   Also known as the Fisher-Tippett distribution or log-Weibull distribution or Gumbel
                    %   distribution
                    %
                    %  pdf(y) = 1/b * exp((mu-y)/b - exp((mu-y)/b)); -Inf<y<Inf; b>0
                    %  cdf(y) = exp(-exp((mu-y)/b)); -Inf<y<Inf; b>0
                    %
                    %   Mean = mu + b*g; where g=5.772156649015329e-001; is the Euler-Mascheroni constant
                    %   Variance = pi^2*b^2/6;
                    %   Skewness = 12*sqrt(6)*zeta3/pi^3; where zeta3=1.20205690315732e+000; is Apery's constant
                    %   Kurtosis = 12/5;
                    %
                    % PARAMETERS:  
                    %   mu - location (-Inf<mu<inf)
                    %   b  - scale (b>0)
                    %
                    % SUPPORT:      
                    %   y,   -Inf<y<Inf
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %
                    % USAGE:
                    %   randraw('extrvalue', [mu b], sampleSize) - generate sampleSize number
                    %         of variates from Extreme-Value distribution with location parameter mu 
                    %         and scale parameter b;
                    %   randraw('extrvalue') - help for Extreme-Value distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('extrvalue', [0 1], [1 1e5]);
                    %  2.   y = randraw('extrvalue', [10 2], 1, 1e5);
                    %  3.   y = randraw('extrvalue', [15.5 4], 1e5 );
                    %  4.   y = randraw('extrvalue', [100 100], [1e5 1] );
                    %  5.   randraw('extrvalue');
                    %
                    % SEE ALSO:
                    %   GUMBEL, WEIBULL distributions
                    % END extrval HELP END extremevalue HELP END extrvalue HELP END gumbel HELP
                                        
                    checkParamsNum(funcName, 'Extreme Value', 'extrvalue', distribParams, [2]);  
                    mu  = distribParams(1);
                    b  = distribParams(2);
                    validateParam(funcName, 'Extreme Value', 'extrvalue', '[mu, b]', 'b', b, {'> 0'});

                    out = mu - b * log(-log( rand( sampleSize )));

               case {'f','fdistribution', 'fdistrib', 'fdistr', 'fdist', 'fdis' }
                    % START f HELP START fdistribution HELP START fdistrib HELP START fdistr HELP START fdist HELP START fdis HELP
                    % THE F-DISTRIBUTION (also Central F-distribution)
                    %
                    %     In statistics and probability, the F-distribution is a continuous
                    %   probability distribution. It is also known as Snedecor's F distribution or
                    %   the Fisher-Snedecor distribution (after Ronald Fisher and George W. Snedecor).
                    %     A random variate of the F-distribution arises as the ratio of two chi-squared
                    %   variates: (U1/d1)/(U2/d2), where U1 and U2 have chi-square distributions with 
                    %   d1 and d2 degrees of freedom respectively, and U1 and U2 are independent.
                    %    The F-distribution arises frequently as the null distribution of a test statistic,
                    %   especially in likelihood-ratio tests, perhaps most notably in the analysis of 
                    %   variance;
                    %
                    %   pdf(y) = 1/beta(d1/2,d2/2) * (d1*y./(d1*y+d2)).^(d1/2) .* (1 - d1*y./(d1*y+d2)).^(d2/2) ./ y;
                    %   cdf(y) = beatinc(d1*y./(d1*y+d2), d1/2, d2/2);
                    %
                    %   Mean = d2/(d2-2), provided d2 > 2;
                    %   Variance = 2*d2^2*(d1+d2-2)/(d1*(d2-2)^2*(d2-4)), provided d2>4;
                    %   Skewness = (2*d1+d2-2)*sqrt(8*(d2-4))/((d2-6)*sqrt(d1*(d1+d2-2))), provided d2>6;
                    %   Mode = (d1-2)/d1 * d2/(d2+2), provided d1>2;
                    %
                    % PARAMETERS:  
                    %   d1 - positive integer
                    %   d2 - positive integer
                    %
                    % SUPPORT:      
                    %   y,   y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('f', [d1 d2], sampleSize) - generate sampleSize number
                    %         of variates from F-distribution with parameters d1 and d2;
                    %   randraw('f') - help for F-distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('f', [2 3], [1 1e5]);
                    %  2.   y = randraw('f', [2 3], 1, 1e5);
                    %  3.   y = randraw('f', [2 3], 1e5 );
                    %  4.   y = randraw('f', [2 3], [1e5 1] );
                    %  5.   randraw('f');
                    % END f HELP END fdistribution HELP END fdistrib HELP END fdistr HELP END fdist HELP END fdis HELP

                    checkParamsNum(funcName, 'F', 'f', distribParams, [2]);                    
                    d1 = distribParams(1);
                    d2 = distribParams(2);                    
                    validateParam(funcName, 'F', 'f', '[d1, d2]', 'd1', d1, {'> 0','==integer'});
                    validateParam(funcName, 'F', 'f', '[d1, d2]', 'd2', d2, {'> 0','==integer'});
                    
                    out = feval(funcName, 'beta', [0.5*d1 0.5*d2], sampleSize);
                    out = d2*out ./ (d1*(1-out));
              
               case {'fnc', 'fnoncentral', 'fnoncentr'}
                    % START fnc HELP START fnoncentral HELP START fnoncentr HELP
                    % THE NONCENTRAL F-DISTRIBUTION
                    %
                    %  The central F distribution is the ratio of 2 central chi-square distributions with 
                    %  d1 and d2 degrees of freedom respectively. The noncentral F distribution is the ratio 
                    %  of a non-central chi-square distribution with d1 degrees of freedom and non-centrality 
                    %  parameter lambda and a central chi-square distribution with degrees of freedom parameter 
                    %  d2. 
                    %  The non-centrality parameter should be non-negative, and both degrees of freedom parameters 
                    %  should be positive.
                    %  
                    %    Mean = (d1+lambda)*d2/(d1*(d2-2)), provided d2 > 2;
                    %    Variance = ( ( d1+lambda )^2 + 2*( d1+lambda )*d2^2 )/( (d2-2)*(d2-4)*d1^2 ) - ...
                    %              (d1+lambda)^2*d2^2/((d2-2)^2*d1^2);  provided d2 > 4;
                    % 
                    % PARAMETERS:  
                    %   lambda - non-centrality parameter (lambda>=0);
                    %   d1     - positive integer
                    %   d2     - positive integer
                    %
                    % SUPPORT:      
                    %   y,   y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('fnoncentral', [lambda d1 d2], sampleSize) - generate sampleSize number
                    %         of variates from noncentral F-distribution with parameters lambda, d1 and d2;
                    %   randraw('fnoncentral') - help for noncentral F-distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('fnoncentral', [1 2 5], [1 1e5]);
                    %  2.   y = randraw('fnoncentral', [2 3 5], 1, 1e5);
                    %  3.   y = randraw('fnoncentral', [6 6 6], 1e5 );
                    %  4.   y = randraw('fnoncentral', [1.1 8 9], [1e5 1] );
                    %  5.   randraw('fnoncentral');
                    %
                    % SEE ALSO:
                    %  F distribution
                    % END fnc HELP END fnoncentral HELP END fnoncentr HELP                    
                    
                    checkParamsNum(funcName, 'noncentral F', 'fnoncentral', distribParams, [3]);
                    
                    lambda = distribParams(1);
                    d1 = distribParams(2);
                    d2 = distribParams(3);
                    
                    validateParam(funcName, 'noncentral F', 'fnoncentral', '[lambda, d1, d2]', 'lambda', lambda, {'>=0'});                    
                    validateParam(funcName, 'noncentral F', 'fnoncentral', '[lambda, d1, d2]', 'd1', d1, {'> 0','==integer'});
                    validateParam(funcName, 'noncentral F', 'fnoncentral', '[lambda, d1, d2]', 'd2', d2, {'> 0','==integer'});
                    
                    chisq1 = feval(funcName, 'chisqnoncentral', [lambda, d1], sampleSize);
                    out = feval(funcName, 'chisq', d2, sampleSize);
                    out = (chisq1/d1) ./ (out/d2);
                    
               case {'gamma'}
                    % START gamma HELP START gama HELP
                    % THE GAMMA DISTRIBUTION
                    %
                    % The standard form of the GAMMA distribution:
                    %
                    %   pdf(y) = y^(a-1)*exp(-y)/gamma(a);  y>=0, a>0
                    %   cdf(y) = gammainc(y, a);
                    %
                    %   Mean = a;
                    %   Variance = a;
                    %   Skewness = 2/sqrt(a);
                    %   Kurtosis = 6/a;
                    %   Mode = a-1;
                    %
                    % The general form of the GAMMA distribution:
                    %
                    %   pdf(y) = ((y-m)/b).^(a-1) .* exp(-(y-m)/b)/ (b*gamma(a));  y>=m; a>0; b>0
                    %   cdf(y) = gammainc((y-m)/b, a);  y>=m; a>0; b>0
                    %
                    %   Mean = m + a*b;
                    %   Variance = a*b^2;
                    %   Skewness = 2/sqrt(a);
                    %   Kurtosis = 6/a;
                    %   Mode = m + b*(a-1);
                    %
                    % PARAMETERS:  
                    %   m - location
                    %   b - scale; b>0
                    %   a - shape; a>0
                    %
                    % SUPPORT:      
                    %   y,   y>=0   - standard GAMMA distribution
                    %    or
                    %   y,   y>=m   - generalized GAMMA distribution
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    % 1. The GAMMA distribution approaches a NORMAL distribution as a goes to Inf                    
                    % 5. GAMMA(m, b, a), where a is an integer, is the Erlang distribution.
                    % 6. GAMMA(m, b, 1) is the Exponential distribution.
                    % 7. GAMMA(0, 2, nu/2) is the Chi-square distribution with nu degrees of freedom.
                    %
                    % USAGE:
                    %   randraw('gamma', a, sampleSize) - generate sampleSize number
                    %         of variates from standard GAMMA distribution with shape parameter 'a'; 
                    %   randraw('gamma', [m, b, a], sampleSize) - generate sampleSize number
                    %         of variates from generalized GAMMA distribution
                    %         with location parameter 'm', scale parameter 'b' and shape parameter 'a';
                    %   randraw('gamma') - help for GAMMA distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('gamma', [2], [1 1e5]);
                    %  2.   y = randraw('gamma', [0 10 2], 1, 1e5);
                    %  3.   y = randraw('gamma', [3], 1e5 );
                    %  4.   y = randraw('gamma', [1/3], 1e5 );
                    %  5.   y = randraw('gamma', [1 3 2], [1e5 1] );
                    %  6.   randraw('gamma');
                    %
                    % END gamma HELP END gama HELP
                    
                    % Method:
                    %
                    % Reference:
                    % George Marsaglia and Wai Wan Tsang, "A Simple Method for Generating Gamma
                    %   Variables": ACM Transactions on Mathematical Software, Vol. 26, No. 3,
                    %   September 2000, Pages 363-372
                    
                    checkParamsNum(funcName, 'Gamma', 'gamma', distribParams, [1, 3]);
                    if numel(distribParams)==3
                         m  = distribParams(1);
                         b  = distribParams(2);
                         a  = distribParams(3);
                         validateParam(funcName, 'Gamma', 'gamma', '[m, b, a]', 'a', a, {'> 0'});
                         validateParam(funcName, 'Gamma', 'gamma', '[m, b, a]', 'b', b, {'> 0'});
                    else
                         m = 0;
                         b = 1;
                         a  = distribParams(1);
                         validateParam(funcName, 'Gamma', 'gamma', '[m, b, a]', 'a', a, {'> 0'});                         
                    end
                    
                    if a < 1
                         % If a<1, one can use GAMMA(a)=GAMMA(1+a)*UNIFORM(0,1)^(1/a);
                         out = m + b*(feval(funcName, 'gamma', 1+a, sampleSize)).*(rand(sampleSize).^(1/a));                         
                         
                    else
                         
                         d = a - 1/3;
                         c = 1/sqrt(9*d);
                         
                         x = randn( sampleSize );
                         v = 1+c*x;
                         
                         indxs = find(v <= 0);
                         while ~isempty(indxs)
                              indxsSize = size( indxs );
                              xNew = randn( indxsSize );
                              vNew = a+c*xNew;
                              
                              l = (vNew > 0);
                              v( indxs( l ) ) = vNew(l);
                              x( indxs( l ) ) = xNew(l);
                              indxs = indxs( ~l );
                         end
                         
                         u = rand( sampleSize );
                         v = v.^3;
                         x2 = x.^2;
                         out = d*v;
                         
                         indxs = find( (u>=1-0.0331*x2.^2) & (log(u)>=0.5*x2+d*(1-v+log(v))) );
                         while ~isempty(indxs)
                              indxsSize = size( indxs );
                              
                              x = randn( indxsSize );
                              v = 1+c*x;
                              indxs1 = find(v <= 0);
                              while ~isempty(indxs1)
                                   indxsSize1 = size( indxs1 );
                                   xNew = randn( indxsSize1 );
                                   vNew = a+c*xNew;
                                   
                                   l1 = (vNew > 0);
                                   v( indxs1(l1) ) = vNew(l1);
                                   x( indxs1(l1) ) = xNew(l1);
                                   indxs1 = indxs1( ~l1 );
                              end
                              
                              u = rand( indxsSize );
                              v = v .* v .* v;
                              x2 = x.*x;
                              
                              l = (u<1-0.0331*x2.*x2) | (log(u)<0.5*x2+d*(1-v+log(v)));
                              out( indxs( l ) ) = d*v(l);
                              indxs = indxs( ~l );
                         end % while ~isempty(indxs)
                         
                         out = m + b*out;
                         
                    end % if a < 1, else ...
               
               case {'geometric', 'geom', 'furry'}
                    % START geometric HELP START geom HELP START furry HELP
                    % THE GEOMETRIC DISTRIBUTION
                    %
                    % pdf(n) = p*(1-p)^(n-1);
                    % 
                    % Mean = 1/p;
                    % Variance = (1-p)/p^2;
                    % Mode = 1;
                    %
                    % PARAMETERS:
                    %    p - probability of success (0<p<1)
                    %
                    % SUPPORT:
                    %   n,  n = 1, 2, 3, 4, ...
                    %
                    % CLASS:
                    %   Discrete distributions
                    %
                    % NOTES:
                    %  1. The Geometric distribution is the discrete version of 
                    %     the Exponential distribution.
                    %  2. The Geometric distribution is sometimes called 
                    %     the Furry distribution.
                    %  3. In a series of Bernoulli trials, with Prob(success) = p, 
                    %     the number of trials required to realize the first 
                    %     success is ~Geometric(p).
                    %  4. For the k'th success, see the Negative Binomial distribution.
                    %
                    % USAGE:
                    %   randraw('geom', p, sampleSize) - generate sampleSize number
                    %         of variates from the Geometric distribution with 
                    %         probability of success 'p'
                    %   randraw('geom') - help for the Geometric distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('geom', 0.1, [1 1e5]);
                    %  2.   y = randraw('geom', 0.22, 1, 1e5);
                    %  3.   y = randraw('geom', 0.5, 1e5 );
                    %  4.   y = randraw('geom', 0.99, [1e5 1] );
                    %  5.   randraw('geom');                          
                    % END geometric HELP END geom HELP END furry HELP
                    
                    checkParamsNum(funcName, 'Geometric', 'geom', distribParams, [1]);  
                    p  = distribParams(1);
                    validateParam(funcName, 'Geometric', 'geom', 'p', 'p', p, {'> 0'});
                    validateParam(funcName, 'Geometric', 'geom', 'p', 'p', p, {'< 1'});
                    
                    out = ceil( log( rand( sampleSize ) ) / log( 1 - p ) );
                    
               case {'gig'}
                    % START gig HELP
                    % THE GENERALIZED INVERSE GAUSSIAN DISTRIBUTION
                    %     GIG(lam, chi, psi)
                    %
                    % pdf = (psi/chi)^(lam/2)*y.^(lam-1)/(2*besselk(lam, sqrt(chi*psi))) .* exp(-1/2*(chi./y + psi*y));  y > 0 
                    %
                    % Mean = sqrt( chi / psi ) * besselk(lam+1,sqrt(chi*psi),1)/besselk(lam,sqrt(chi*psi),1);
                    % Variance = chi/psi * besselk(lam+2,sqrt(chi*psi),1)/besselk(lam,sqrt(chi*psi),1) - Mean^2;
                    %
                    % PARAMETERS:
                    %   chi>0,  psi>=0  if lam<0;
                    %   chi>0,  psi>0   if lam=0;
                    %   chi>=0, psi>0   if lam>0;
                    %
                    % SUPPORT:
                    %   y,  y >= 0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %    1) GIG(lam, chi, psi) = 1/c * GIG(lam, chi*c, psi/c), for all c>=0
                    %    2) GIG(lam, chi, psi) = sqrt(chi/psi) * GIG(lam, sqrt(psi*chi), sqrt(psi*chi));
                    %    3) GIG(lam, chi, psi) = 1 / GIG(-lam, psi, chi);
                    %   
                    %   Special cases of GIG distribution are the gamma distribution (chi=0), the
                    %     reciprocal gamma distribution (psi=0), the inverse Gaussian distribution
                    %     (lam = -1/2), and the inverse Gaussian or random walk distribution (lam=1/2).
                    %
                    % USAGE:
                    %   randraw('gig', [lam, chi, psi], sampleSize) - generate sampleSize number
                    %         of variates from the Generalized Inverse Gaussian distribution with 
                    %         parameters 'lam', 'chi' and 'psi'
                    %   randraw('gig') - help for the Generalized Inverse Gaussian distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('gig', [-1, 2, 0], [1 1e5]);
                    %  2.   y = randraw('gig', [2, 3, 4], 1, 1e5);
                    %  3.   y = randraw('gig', [0, 1.1, 2.2], 1e5 );
                    %  4.   y = randraw('gig', [2.5, 3.5, 4.5], [1e5 1] );
                    %  5.   y = randraw('gig', [0.5, 0.6, 0.7], [1e5 1] );
                    %  6.   randraw('gig');                       
                    % END gig HELP
                    
                    % Reference:
                    %  1. Dagpunar, J.S., "Principles of random variate generation,"
                    %        Clarendon Press, Oxford, 1988.   ISBN 0-19-852202-9
                    %  2. Dagpunar, J.S., "An easily implemented generalized inverse Gaussian generator,"
                    %        Commun. Statist. Simul. 18(2), 1989, pp 703-710.
                    
                    checkParamsNum(funcName, 'Generalized Inverse Gaussian', 'gig', distribParams, [3]);
                    lam = distribParams(1);
                    chi = distribParams(2);
                    psi = distribParams(3);
                    
                    if lam < 0,
                         validateParam(funcName, 'Generalized Inverse Gaussian', 'gig', '[lambda, chi, psi]', 'chi', chi, {'> 0'});
                         validateParam(funcName, 'Generalized Inverse Gaussian', 'gig', '[lambda, chi, psi]', 'psi', psi, {'>=0'});
                    elseif lam > 0,
                         validateParam(funcName, 'Generalized Inverse Gaussian', 'gig', '[lambda, chi, psi]', 'chi', chi, {'>=0'});
                         validateParam(funcName, 'Generalized Inverse Gaussian', 'gig', '[lambda, chi, psi]', 'psi', psi, {'> 0'});
                    else % lam==0
                         validateParam(funcName, 'Generalized Inverse Gaussian', 'gig', '[lambda, chi, psi]', 'chi', chi, {'> 0'});
                         validateParam(funcName, 'Generalized Inverse Gaussian', 'gig', '[lambda, chi, psi]', 'psi', psi, {'> 0'});                         
                    end
                    
                    if chi == 0,
                         % Gamma distribution: Gamma(m=0, b=2/psi, lam)
                         out = feval(funcName, 'gamma', [0, 2/psi, lam], sampleSize);
                         varargout{1} = out;
                         return;
                    end
                    
                    if psi == 0,
                         % Reciprocal Gamma distribution: Gamma(m=0, b=2/chi, -lam)
                         out = feval(funcName, 'gamma', [0, 2/chi, -lam], sampleSize);
                         varargout{1} = 1./out;
                         return;
                    end
                    
                    h = lam;
                    b = sqrt( chi * psi );
                                        
                    if h<=1 & b<=1                         
                         % without shifting by m                        
                                                 
                         ym = (-h-1 + sqrt((h+1)^2 + b^2))/b;                         
                         xm = ( h-1 + sqrt((h-1)^2 + b^2))/b;
                         % a = vplus/uplus
                         a = exp(-0.5*h*log(xm*ym) + 0.5*log(xm/ym) + b/4*(xm + 1/xm - ym - 1.0/ym));
                         % c = 1/log(sqrt(hx(xm)))
                         c = -(h-1)/2* log(xm) + b/4*(xm + 1/xm);
                         % vminus = 0

                         u = rand( sampleSize );
                         v = rand( sampleSize );
                         out = a * (v./u);
                         indxs = find( log(u) > (h-1)/2*log(out) - b/4*(out + 1./out) + c );
                         while ~isempty( indxs )
                              indxsSize = size( indxs );
                              u = rand( indxsSize );
                              v = rand( indxsSize );
                              outNew = a * (v./u);
                              l = log(u) <= (h-1)/2*log(outNew) - b/4*(outNew + 1./outNew) + c;
                              out( indxs( l ) ) = outNew(l);
                              indxs = indxs( ~l );
                         end                      

                    else % if h<=1 & b<=1
                         % with shifting by m
                         
                         % Mode of the reparameterized distribution GIG(lam, b, b)
                         m = ( h-1+sqrt((h-1)^2+b^2) ) / b;  % Mode
                         log_1_over_pm = -(h-1)/2*log(m) + b/4*(m + (1/m));
                         
                         r = (6*m + 2*h*m - b*m^2 + b)/(4*m^2);
                         s = (1 + h - b*m)/(2*m^2);
                         p = (3*s - r^2)/3;
                         q = (2*r^3)/27 - (r*s)/27 + b/(-4*m^2);
                         eta = sqrt(-(p^3)/27);
                         
                         y1  = 2*exp(log(eta)/3) * cos(acos(-q/(2*eta))/3) - r/3;
                         y2  = 2*exp(log(eta)/3) * cos(acos(-q/(2*eta))/3 + 2/3*pi) - r/3;


                         vplus = exp( log_1_over_pm + log(1/y1) + (h-1)/2*log(1/y1 + m) - ...
                              b/4*(1/y1 + m + 1/(1/y1 + m)) );
                         vminus = -exp( log_1_over_pm + log(-1/y2) + (h-1)/2*log(1/y2 + m) - ...
                              b/4*(1/y2 + m + 1/(1/y2 + m)) );  
                         
                         u = rand( sampleSize );
                         v = vminus + (vplus - vminus) * rand( sampleSize );
                         z = v ./ u;
                         clear('v');
                         indxs = find( z < -m );
                         
                         while ~isempty(indxs),
                              indxsSize = size( indxs );
                              uNew = rand( indxsSize );
                              vNew = vminus + (vplus - vminus) * rand( indxsSize );
                              zNew = vNew ./ uNew;
                              l = (zNew >= -m);
                              z( indxs( l ) ) = zNew(l);
                              u( indxs( l ) ) = uNew(l);
                              indxs = indxs( ~l );
                         end
                         
                         out = z + m;
                         indxs = find( log(u) > (log_1_over_pm + (h-1)/2*log(out) - b/4*(out + 1./out)) );
                         
                         while ~isempty(indxs),
                              indxsSize = size( indxs );                             
                              u = rand( indxsSize );
                              v = vminus + (vplus - vminus) * rand( indxsSize );
                              z = v ./ u;
                              clear('v');
                              indxs1 = find( z < -m );
                              while ~isempty(indxs1),
                                   indxsSize1 = size( indxs1 );
                                   uNew = rand( indxsSize1 );
                                   vNew = vminus + (vplus - vminus) * rand( indxsSize1 );
                                   zNew = vNew ./ uNew;
                                   l = (zNew >= -m);
                                   z( indxs1( l ) ) = zNew(l);
                                   u( indxs1( l ) ) = uNew(l);
                                   indxs1 = indxs1( ~l );
                              end
                              
                              outNew = z + m;
                              l = ( log(u) <= (log_1_over_pm + (h-1)/2*log(outNew) - b/4*(outNew + 1./outNew)) );
                              out( indxs(l) ) = outNew( l );
                              indxs = indxs( ~l );
                              
                         end
                         
                    end %% if h<=1 & b<=1, else ...
 
                    out = sqrt( chi / psi ) * out;
                    
               case {'gh'}
                    % START gh HELP
                    % THE GENERALIZED HYPERBOLIC DISTRIBUTION
                    %   GH(lam, alpha, beta, mu, delta)
                    %
                    %  pdf =  (alpha^2-beta^2)^(lam/2) / (sqrt(2*pi) * alpha^(lam-1/2) * delta^lam * ... 
                    %                   besselk(lam, delta*sqrt(alpha^2-beta^2) ) ) * ...
                    %            (delta^2 + (y-mu).^2).^(1/2*(lam-1/2)) .* ...
                    %             besselk( lam-1/2, alpha*sqrt(delta^2 + (y-mu).^2) ) .* ...
                    %             exp( beta*(y-mu) );
                    %
                    %  Mean = mu + beta*delta^2/(delta*sqrt(alpha^2-beta^2)) * besselk(lam+1, delta*sqrt(alpha^2-beta^2) ) / ...
                    %           besselk(lam, delta*sqrt(alpha^2-beta^2) );                    
                    %  Variance = delta^2 * ( besselk(lam+1, zeta)/(zeta*besselk(lam, zeta)) + ...
                    %               beta^2*delta^2/zeta^2 * (besselk(lam+2, zeta)/besselk(lam, zeta) - ...
                    %               (besselk(lam+1, zeta)/besselk(lam, zeta))^2) );
                    %       where zeta = delta*sqrt(alpha^2-beta^2);
                    %
                    % PARAMETERS:
                    %     lam,  -Inf < lam < Inf;
                    %     alpha - shape parameter (alpha>0) (steepness)
                    %     beta -  0 <= abs(beta) < alpha  (skewness)
                    %     mu - location parameter (-Inf < mu < Inf)
                    %     delta - scale parameter (delta > 0)       
                    %
                    % SUPPORT:
                    %   y,  -Inf < y < Inf;
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('gh', [lam, alpha, beta, mu, delta], sampleSize) - generate sampleSize number
                    %         of variates from the Generalized Hyperbolic distribution with 
                    %         parameters [lam, alpha, beta, mu, delta]
                    %   randraw('gh') - help for the Generalized Hyperbolic distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('gh', [3, 4, 3, 7.5, 1.5], [1 1e5]);
                    %  2.   y = randraw('gh', [3, 4, 3, 8.5, 1.5], 1, 1e5);
                    %  3.   y = randraw('gh', [3, 4, 3, 9.5, 1.5], 1e5 );
                    %  4.   y = randraw('gh', [3, 4, 3, 12.5, 1.5], [1e5 1] );
                    %  5.   randraw('gh');                      
                    % END gh HELP                    
                    
                    checkParamsNum(funcName, 'GH', 'gh', distribParams, [5]);
                      
                    lam   = distribParams(1);
                    alpha = distribParams(2);
                    beta  = distribParams(3);
                    mu    = distribParams(4);
                    delta = distribParams(5);
                    
                                        
                    validateParam(funcName, 'GH', 'gh', '[lam, alpha, beta, mu, delta]', 'alpha', alpha, {'> 0'});
                    validateParam(funcName, 'GH', 'gh', '[lam, alpha, beta, mu, delta]', 'delta', delta, {'> 0'});
                    validateParam(funcName, 'GH', 'gh', '[lam, alpha, beta, mu, delta]', 'alpha-abs(beta)', alpha-abs(beta), {'> 0'});
                    
                    ygig = feval(funcName, 'gig', [lam, delta^2, alpha^2-beta^2], sampleSize);
                    
                    out = mu + beta*ygig + sqrt(ygig).*randn( sampleSize );
                    
               case {'gompertz'}
                    % START gompertz HELP
                    % THE GOMPERTZ DISTRIBUTION
                    %
                    %  pdf(y) = b * c.^y * exp(-b*(c.^y-1)/log(c)); y>=0; b>0; c>1
                    %  cdf(y) = 1 - exp(-b*(c.^y-1)/log(c)); y>=0; b>0; c>1
                    %
                    %  Mean = exp(b/log(c)) * (-1/log(c)) * (-expint(b/log(c)));
                    %  Variance = 
                    %
                    % PARAMETERS:  
                    %   b - shape parameter (b>0)
                    %   c - shape parameter (c>1)
                    %
                    % SUPPORT:      
                    %   y,   y>=0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %   There are several forms given for the Gompertz distribution in the literature.
                    %   In particular, one common form uses the parameter alpha where alpha=log(c).
                    %   
                    %   The Gompertz distribution is frequently used by actuaries as a distribution 
                    %   of length of life.
                    %
                    % USAGE:
                    %   randraw('gompertz', [b, c], sampleSize) - generate sampleSize number
                    %         of variates from Gompertz distribution with shape parameters 'b' 
                    %         and 'c';
                    %   randraw('gompertz') - help for Gompertz distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('gompertz', [1 2], [1 1e5]);
                    %  2.   y = randraw('gompertz', [2 3], 1, 1e5);
                    %  3.   y = randraw('gompertz', [1.1 5], 1e5 );
                    %  4.   y = randraw('gompertz', [2.3 4.8], [1e5 1] );
                    %  5.   randraw('gompertz');                    
                    % END gompertz HELP    
                    
                    % Method:
                    %
                    % Inverse CDF transformation method.
                    %
                    % Reference:
                    %   
                    %  Dennis Kunimura, "The Compertz Distribution - Estimation of Parameters,"
                    %    Actuarial Research Clearing House, 1998, Vol.2
                    checkParamsNum(funcName, 'Gompertz', 'gompertz', distribParams, [2]);  
                    b  = distribParams(1);
                    c  = distribParams(2);
                    validateParam(funcName, 'Gompertz', 'gompertz', '[b, c]', 'b', b, {'> 0'});
                    validateParam(funcName, 'Gompertz', 'gompertz', '[b, c]', 'c', c, {'> 1'});
                    
                    out = log( 1 - log(1-rand(sampleSize))*log(c)/b ) / log(c);                    

               case {'halfcosine', 'hcosine', 'hcos'}
                    % START halfcosine HELP
                    % THE HALF-COSINE DISTRIBUTION
                    %
                    % Standard Half-cosine distribution:
                    %   pdf(y) = 1/4 * cos( y/2 );  -pi <= y <= pi
                    %   cdf(y) = 1/2 * ( 1 + sin( y/2 ) );   -pi <= y <= pi
                    %
                    %  Mean = 0;
                    %  Variance = pi^2-8;
                    %
                    % General half-cosine distribution:
                    %   pdf(y) = pi/(4*a) * cos( pi*(y-t)/(2*s) );  t-s <= y <= t+s
                    %   cdf(y) = 1/2 * ( 1 + sin( pi*(y-t)/(2*s) ) );   t-s <= y <= t+s
                    %
                    %  Mean = t;
                    %  Variance = (1-8/pi^2)*s^2;
                    %
                    % PARAMETERS:  
                    %   t - location
                    %   s -scale; s>0
                    %
                    % SUPPORT:      
                    %   y,   -pi <= y <= pi   - standard Half-cosine distribution
                    %    or
                    %   y,   t-s <= y <= t+s  - generalized Half-cosine distribution
                    %
                    % CLASS:
                    %   Continuous distributions
                    %
                    % USAGE:
                    %   randraw('halfcosine', [], sampleSize) - generate sampleSize number
                    %         of variates from standard  Half-cosine distribution;
                    %   randraw('halfcosine', [t, s], sampleSize) - generate sampleSize number
                    %         of variates from generalized  Half-cosine distribution
                    %         with location parameter 't' and scale parameter 's';
                    %   randraw('halfcosine') - help for Half-cosine distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('halfcosine', [], [1 1e5]);
                    %  2.   y = randraw('halfcosine', [], 1, 1e5);
                    %  3.   y = randraw('halfcosine', [], 1e5 );
                    %  4.   y = randraw('halfcosine', [10 3], [1e5 1] );
                    %  5.   randraw('halfcosine');
                    %
                    % END halfcosine HELP
                    
                    checkParamsNum(funcName, 'Half-Cosine', 'halfcosine', distribParams, [0, 2]);  
                    if numel(distribParams)==2
                         t  = distribParams(1);
                         s  = distribParams(2);  
                         validateParam(funcName, 'Half-Cosine', 'halfcosine', '[t, s]', 's', s, {'> 0'});
                    else
                         t = 0;
                         s = pi;                        
                    end                       
                    
                    out = t + s*2/pi*asin(2*rand(sampleSize)-1);
                    
               case {'hyperbolicsecant', 'hsecant', 'hsec'}
                    % START hsecant HELP START hsec HELP START hyperbolicsecant HELP
                    % THE HYPERBOLIC SECANT DISTRIBUTION
                    %
                    %  Standard form of the Hyperbolic Secant distribution
                    %    pdf(y) = sech(y)/pi;
                    %    cdf(y) = 2*atan(exp(y))/pi; 
                    %
                    %    Mean = Median = Mode = 0;
                    %    Variance = pi^2/4;
                    %    Skewness = 0;
                    %    Kurtosis = 2;
                    %
                    %  General form of the Hyperbolic Secant distribution
                    %    pdf(y) = sech((y-a)/b)/(b*pi);
                    %    cdf(y) = 2*atan(exp((y-a)/b))/pi;                    
                    %
                    %    Mean = Median = Mode = a;
                    %    Variance = (pi*b)^2/4;
                    %    Skewness = 0;
                    %    Kurtosis = 2;
                    %
                    % PARAMETERS:  
                    %    a - location;
                    %    b - scale; (b>0)
                    %                      
                    % SUPPORT:      
                    %   y,   -Inf < y < Inf 
                    %
                    % CLASS:
                    %   Continuous symmetric distributions
                    %
                    % NOTES:
                    %  1. The Hyperbolic Secant is related to the Logistic distribution.
                    %  2. If Z ~Hyperbolic Secant, then W = exp(Z) ~Half Cauchy.
                    %  3. The Hyperbolic Secant distribution is used in lifetime analysis.
                    %
                    % USAGE:
                    %   randraw('hsecant', [], sampleSize) - generate sampleSize number
                    %         of variates from standard Hyperbolic Secant distribution;                    
                    %   randraw('hsecant', [a, b], sampleSize) - generate sampleSize number
                    %         of variates from generalized Hyperbolic Secant distribution
                    %         with location parameter 'a' and scale parameter 'b';
                    %   randraw('hsecant') - help for Hyperbolic Secant distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('hsecant', [], [1 1e5]);
                    %  2.   y = randraw('hsecant', [-1 4], 1, 1e5);
                    %  3.   y = randraw('hsecant', [], 1e5 );
                    %  4.   y = randraw('hsecant', [10.1 3.2], [1e5 1] );
                    %  5.   randraw('hsecant');                    
                    % END hsecant HELP END hsec HELP END hyperbolicsecant HELP
                    
                    checkParamsNum(funcName, 'Hyperbolic Secant', 'hsecant', distribParams, [0, 2]);  
                    if numel(distribParams)==2
                         a  = distribParams(1);
                         b  = distribParams(2);  
                         validateParam(funcName, 'Hyperbolic Secant', 'hsecant', '[a, b]', 'b', b, {'> 0'});
                    else
                         a = 0;
                         b = 1;                        
                    end   
                    
                    out = a + b* log(tan(pi/2*rand(sampleSize)));
                    
               case {'hypergeom', 'hypergeometric'}
                    % START hypergeom HELP START hypergeometric HELP
                    % THE HYPERGEOMETRIC DISTRIBUTION
                    % If Y is the number of SUCCESSES in a completely random sample of size n drawn from
                    % a population consisting of M SUCCESSES and (N-M) FAILURES, then Y distributed according
                    %  to Hypergeometric distribution
                    %
                    % pdf(y) = nchoosek(M,y)*nchoosek(N-M,n-y) / nchoosek(N,n) = ...
                    %          exp( gammaln(M+1) - gammaln(M-y+1) - gammaln(y+1) + ...
                    %               gammaln(N-M+1) - gammaln(N-M-n+y+1) - gammaln(n-y+1) + ...
                    %               gammaln(n+1) + gammaln(N-n+1) - gammaln(N+1) );
                    %
                    %    max(0, n-N+M) <= y <= min(n,M)
                    %
                    % Mean = n*(M/N);
                    % Variance = (N-n)/(N-1)*n*M/N*(1-M/N);
                    % Mode = floor( (M+1)*(n+1)/(N+2) );
                    %
                    % PARAMETERS:
                    %   N,   N = 2, 3, 4, ...
                    %   M,   0 < M < N
                    %   n,   0 < n < N
                    %
                    % SUPPORT:
                    %   y,  y is integer and  max(0, n-N+M) <= y <= min(n,M), 
                    %
                    % CLASS:
                    %   Discrete distributions                    
                    %
                    % NOTES:
                    %  1. In the urn model: 
                    %     From an urn with white and black balls a random sample is drawn without
                    %     replacement, then
                    %     N = total number of balls in the urn;
                    %     M = number of white balls in the urn;
                    %     n = sample size (number of balls drawn without replacement);
                    %     Y = number of white balls in the sample.
                    %
                    %  2. When the population size is large (i.e. N is large) the hypergeometric 
                    %     distribution can be approximated reasonably well with a binomial 
                    %     distribution with parameters n (number of trials) and p = M / N 
                    %     (probability of success in a single trial).
                    %
                    % USAGE:
                    %   randraw('hypergeom', [N, M, n], sampleSize) - generate sampleSize number
                    %         of variates from the  Hypergeometric distribution
                    %         with parameters N, M and n;
                    %   randraw('hypergeom') - help for the  Hypergeometric distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('hypergeom', [20 13 17], [1 1e5]);
                    %  2.   y = randraw('hypergeom', [30 22 14], 1, 1e5);
                    %  3.   y = randraw('hypergeom', [50 3  22], 1e5 );
                    %  4.   y = randraw('hypergeom', [33 32 10], [1e5 1] );
                    %  5.   randraw('hypergeom');      
                    % 
                    % SEE ALSO:
                    %  BINOMIAL distribution
                    % END hypergeom HELP END hypergeometric HELP

                    checkParamsNum(funcName, 'Hypergeometric', 'hypergeom', distribParams, [3]);
                    N = distribParams(1);
                    M = distribParams(2);
                    n = distribParams(3);
                    validateParam(funcName, 'Hypergeometric', 'hypergeom', '[N, M, n]', 'N', N, {'> 1', '==integer'});
                    validateParam(funcName, 'Hypergeometric', 'hypergeom', '[N, M, n]', 'M', M, {'> 0', '==integer'});
                    validateParam(funcName, 'Hypergeometric', 'hypergeom', '[N, M, n]', 'n', n, {'> 0', '==integer'});
                    validateParam(funcName, 'Hypergeometric', 'hypergeom', '[N, M, n]', 'N-M', N-M, {'> 0'});
                    validateParam(funcName, 'Hypergeometric', 'hypergeom', '[N, M, n]', 'N-n', N-n, {'> 0'});
                                        
                    mode = floor( (M+1)/(N+2)*(n+1) );
                    if ~isfinite(mode)
                         warning('Numeric Overflow !');
                         varargout{1} = [];
                         return;
                    end
                    pmode = exp( gammaln(M+1) - gammaln(M-mode+1) - gammaln(mode+1) + ...
                         gammaln(N-M+1) - gammaln(N-M-n+mode+1) - gammaln(n-mode+1) + ...
                         gammaln(n+1) + gammaln(N-n+1) - gammaln(N+1) );

                    if pmode < 5e-10
                         varargout{1} = repmat(mode, sampleSize);
                         return;                         
                    end
                    
                    if ~isfinite(pmode)
                         varargout{1} = feval(funcName, 'binomial', [n M/N], sampleSize);
                    end
                    if pmode==1,
                         varargout{1} = repmat(mode, sampleSize);
                         return;
                    end
                    % nchoosek(M,y)*nchoosek(N-M,n-y) / nchoosek(N,n)
                    t=pmode;
                    ii = mode+1;
                    while t*2147483648 > 1
                         t = t * (M-ii+1)/(ii) *(n-ii+1)/(N-M-n+ii);
                         ii = ii + 1;
                    end 
                    last=ii-2;
                                   
                    t=pmode;
                    j=-1;
                    for ii=mode-1:-1:0 
                         t = t * (ii+1)/(M-ii) *(N-M-n+ii+1)/(n-ii);
                         if t*2147483648 < 1
                              j=ii;
                              break;
                         end
                    end                    
                    offset=j+1;
                    sizeP=last-offset+1;

                    P = zeros(1, sizeP);

                    ii = (mode+1):last;
                    P(mode-offset+1:last-offset+1) = round( 2^30*pmode*cumprod([1, (M-ii+1)./(ii).*(n-ii+1)./(N-M-n+ii)] ) );
                    
                    ii = (mode-1):-1:offset;
                    P(mode-offset:-1:1) = round( 2^30*pmode*cumprod((ii+1)./(M-ii).*(N-M-n+ii+1)./(n-ii)) );
                             
                    out = randFrom5Tbls( P, offset, sampleSize);
                       
                                   
               case {'ig', 'inversegauss', 'invgauss'}                   
                    %
                    % START ig HELP START inversegauss HELP  START invgauss HELP
                    % THE INVERSE GAUSSIAN DISTRIBUTION
                    %
                    % The Inverse Gaussian distribution is left skewed distribution whose
                    % location is set by the mean with the profile determined by the
                    % scale factor.  The random variable can take a value between zero and
                    % infinity.  The skewness increases rapidly with decreasing values of
                    % the scale parameter.
                    %
                    %
                    % pdf(y) = sqrt(chi/(2*pi*y^3)) * exp(-chi./(2*y).*(y/theta-1).^2);
                    % cdf(y) = normcdf(sqrt(chi./y).*(y/theta-1)) + ...
                    %            exp(2*chi/theta)*normcdf(sqrt(chi./y).*(-y/theta-1));
                    %
                    %   where  normcdf(x) = 0.5*(1+erf(y/sqrt(2))); is the standard normal CDF
                    %         
                    % Mean     = theta;
                    % Variance = theta^3/chi;
                    % Skewness = sqrt(9*theta/chi);
                    % Kurtosis = 15*mean/scale;
                    % Mode = theta/(2*chi)*(sqrt(9*theta^2+4*chi^2)-3*theta);
                    %
                    % PARAMETERS:
                    %  theta - location; (theta>0)
                    %  chi - scale; (chi>0)
                    %
                    % SUPPORT:
                    %  y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distribution
                    %
                    % NOTES:
                    %   1. There are several alternate forms for the PDF, 
                    %      some of which have more than two parameters
                    %   2. The Inverse Gaussian distribution is often called the Inverse Normal
                    %   3. Wald distribution is a special case of The Inverse Gaussian distribution
                    %      where the mean is a constant with the value one.
                    %   4. The Inverse Gaussian distribution is a special case of The Generalized
                    %        Hyperbolic Distribution
                    %
                    % USAGE:
                    %   randraw('ig', [theta, chi], sampleSize) - generate sampleSize number
                    %         of variates from the Inverse Gaussian distribution with 
                    %         parameters theta and chi;
                    %   randraw('ig') - help for the Inverse Gaussian distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('ig', [0.1, 1], [1 1e5]);
                    %  2.   y = randraw('ig', [3.2, 10], 1, 1e5);
                    %  3.   y = randraw('ig', [100.2, 6], 1e5 );
                    %  4.   y = randraw('ig', [10, 10.5], [1e5 1] );
                    %  5.   randraw('ig');
                    % 
                    % SEE ALSO:
                    %   WALD distribution
                    % END ig HELP END inversegauss HELP  END invgauss HELP 
                    
                    % Method:
                    %
                    % There is an efficient procedure that utilizes a transformation
                    % yielding two roots.
                    % If Y is Inverse Gauss random variable, then following to [1]
                    % we can write:
                    % V = chi*(Y-theta)^2/(Y*theta^2) ~ Chi-Square(1),
                    %
                    % i.e. V is distributed as a chi-square random variable with
                    % one degree of freedom.
                    % So it can be simply generated by taking a square of a
                    % standard normal random number.
                    % Solving this equation for Y yields two roots:
                    %
                    % y1 = theta + 0.5*theta/chi * ( theta*V - sqrt(4*theta*chi*V + ...
                    %      theta^2*V.^2) );
                    % and
                    % y2 = theta^2/y1;
                    %
                    % In [2] showed that  Y can be simulated by choosing y1 with probability
                    % theta/(theta+y1) and y2 with probability 1-theta/(theta+y1)
                    %
                    % References:
                    % [1] Shuster, J. (1968). On the Inverse Gaussian Distribution Function,
                    %         Journal of the American Statistical Association 63: 1514-1516.
                    %
                    % [2] Michael, J.R., Schucany, W.R. and Haas, R.W. (1976).
                    %     Generating Random Variates Using Transformations with Multiple Roots,
                    %     The American Statistician 30: 88-90.
                    %
                    %

                    checkParamsNum(funcName, 'Inverse Gaussian', 'ig', distribParams, [2]);
                    theta = distribParams(1);
                    chi = distribParams(2);
                    validateParam(funcName, 'Inverse Gaussian', 'ig', '[theta, chi]', 'theta', theta, {'> 0'});
                    validateParam(funcName, 'Inverse Gaussian', 'ig', '[theta, chi]', 'chi', chi, {'> 0'});

                    chisq1 = randn(sampleSize).^2;
                    out = theta + 0.5*theta/chi * ( theta*chisq1 - ...
                         sqrt(4*theta*chi*chisq1 + theta^2*chisq1.^2) );

                    l = rand(sampleSize) >= theta./(theta+out);
                    out( l ) = theta^2./out( l );

               case {'laplace' 'doubleexponential', 'doubleexp', 'bilateralexponential', 'bilateralexp'}
                    % START laplace HELP START doubleexponential HELP START doubleexp HELP START bilateralexponential HELP START bilateralexp HELP
                    % THE LAPLACE DISTRIBUTION
                    % (sometimes: double-exponential or bilateral exponential distribution)
                    %
                    % pdf = 1/(2*lam)*exp(-abs(y-theta)/lam);
                    % cdf = (y<=theta) .* 1/2*exp((y-theta)/lam) + (y>theta) .* (1 - 1/2*exp((theta-y)/lam));
                    %
                    % Mean = Median = Mode = theta;
                    % Variance = 2*lam^2;
                    % Skewness = 0;
                    % Kurtosis = 3;
                    %
                    % PARAMETERS:
                    %   theta  - location
                    %   lam   -  scale  (lam>0)
                    %
                    % SUPPORT:
                    %   y ,   -Inf < y < Inf
                    %
                    % CLASS:
                    %   Continuous symmetric distribution   
                    %
                    % USAGE:
                    %   randraw('laplace', [], sampleSize) - generate sampleSize number
                    %         of variates from the Laplace distribution with 
                    %         loaction parameter theta=0 and scale parameter lam=1;                    
                    %   randraw('laplace', [theta, lam], sampleSize) - generate sampleSize number
                    %         of variates from the Laplace distribution with 
                    %         loaction parameter theta and scale parameter lam;
                    %   randraw('laplace') - help for the Laplace distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('laplace', [0, 1], [1 1e5]);
                    %  2.   y = randraw('laplace', [3.2, 10], 1, 1e5);
                    %  3.   y = randraw('laplace', [100.2, 6], 1e5 );
                    %  4.   y = randraw('laplace', [10, 10.5], [1e5 1] );
                    %  5.   randraw('laplace');                    
                    % END laplace HELP END doubleexponential HELP END doubleexp HELP END bilateralexponential HELP END bilateralexp HELP

                    checkParamsNum(funcName, 'Laplace', 'laplace', distribParams, [0, 2]);
                    if numel(distribParams)==2
                         theta  = distribParams(1);
                         lam  = distribParams(2);
                         validateParam(funcName, 'Laplace', 'laplace', '[theta, lam]', 'lam', lam, {'> 0'});
                    else
                         theta = 0;
                         lam = 1;
                    end
                    
                    u = rand( sampleSize );
                    out = zeros( sampleSize );
                    out(u<=0.5) = theta + lam*log(2*u(u<=0.5));
                    out(u>0.5) = theta - lam*log(2*(1-u(u>0.5)));
                    
               case {'logistic'}
                    % START logistic HELP
                    % THE LOGISTIC DISTRIBUTION
                    %   The logistic distribution is a symmetrical bell shaped distribution.
                    %   One of its applications is an alternative to the Normal distribution
                    %   when a higher proportion of the population being modeled is
                    %   distributed in the tails.
                    %
                    %  pdf(y) = exp((y-a)/k)./(k*(1+exp((y-a)/k)).^2);
                    %  cdf(y) = 1 ./ (1+exp(-(y-a)/k))
                    %
                    %  Mean = a;
                    %  Variance = k^2*pi^2/3;
                    %  Skewness = 0;
                    %  Kurtosis = 1.2;
                    %
                    % PARAMETERS:
                    %  a - location;
                    %  k - scale (k>0);
                    %
                    % SUPPORT:
                    %   y,  -Inf < y < Inf
                    %
                    % CLASS:
                    %   Continuous symmetric distribution                      
                    %
                    % USAGE:
                    %   randraw('logistic', [], sampleSize) - generate sampleSize number
                    %         of variates from the standard Logistic distribution with 
                    %         loaction parameter a=0 and scale parameter k=1;                    
                    %   randraw('logistic', [a, k], sampleSize) - generate sampleSize number
                    %         of variates from the Logistic distribution with 
                    %         loaction parameter 'a' and scale parameter 'k';
                    %   randraw('logistic') - help for the Logistic distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('logistic', [], [1 1e5]);
                    %  2.   y = randraw('logistic', [0, 4], 1, 1e5);
                    %  3.   y = randraw('logistic', [-1, 10.2], 1e5 );
                    %  4.   y = randraw('logistic', [3.2, 0.3], [1e5 1] );
                    %  5.   randraw('logistic');                       
                    % END logistic HELP
                    
                    % Method:
                    %
                    % Inverse CDF transformation method.

                    checkParamsNum(funcName, 'Logistic', 'logistic', distribParams, [0, 2]);
                    if numel(distribParams)==2
                         a  = distribParams(1);
                         k  = distribParams(2);
                         validateParam(funcName, 'Laplace', 'laplace', '[a, k]', 'k', k, {'> 0'});
                    else
                         a = 0;
                         k = 1;
                    end

                    u1 = rand( sampleSize );
                    out = a - k*log( 1./u1 - 1 );

               case { 'lognorm', 'lognormal', 'cobbdouglas', 'antilognormal' }
                    % START lognorm HELP START lognormal HELP START cobbdouglas HELP START antilognormal HELP
                    % THE LOG-NORMAL DISTRIBUTION
                    % (sometimes: Cobb-Douglas or antilognormal distribution)
                    %
                    % pdf = 1/(k*sqrt(2*pi)) * exp(-1/2*((log(y)-a)/k)^2)
                    % cdf = 1/2*(1 + erf((log(y)-a)/(k*sqrt(2))));
                    % 
                    % Mean = exp( a + k^2/2 );
                    % Variance = exp(2*a+k^2)*( exp(k^2)-1 );
                    % Skewness = (exp(1)+2)*sqrt(exp(1)-1), for a=0 and k=1;
                    % Kurtosis = exp(4) + 2*exp(3) + 3*exp(2) - 6; for a=0 and k=1;
                    % Mode = exp(a-k^2);
                    %
                    % PARAMETERS:
                    %  a - location
                    %  k - scale (k>0)
                    %
                    % SUPPORT:
                    %   y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distribution                      
                    %
                    % NOTES:
                    %  1) The LogNormal distribution is always right-skewed
                    %  2) Parameters a and k are the mean and standard deviation 
                    %     of y in (natural) log space.
                    %
                    % USAGE:
                    %   randraw('lognorm', [], sampleSize) - generate sampleSize number
                    %         of variates from the standard Lognormal distribution with 
                    %         loaction parameter a=0 and scale parameter k=1;                    
                    %   randraw('lognorm', [a, k], sampleSize) - generate sampleSize number
                    %         of variates from the Lognormal distribution with 
                    %         loaction parameter 'a' and scale parameter 'k';
                    %   randraw('lognorm') - help for the Lognormal distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('lognorm', [], [1 1e5]);
                    %  2.   y = randraw('lognorm', [0, 4], 1, 1e5);
                    %  3.   y = randraw('lognorm', [-1, 10.2], 1e5 );
                    %  4.   y = randraw('lognorm', [3.2, 0.3], [1e5 1] );
                    %  5.   randraw('lognorm');                                           
                    %END lognorm HELP END lognormal HELP END cobbdouglas HELP END antilognormal HELP
                    
                    checkParamsNum(funcName, 'Lognormal', 'lognorm', distribParams, [0, 2]);
                    if numel(distribParams)==2
                         a  = distribParams(1);
                         k  = distribParams(2);
                         validateParam(funcName, 'Lognormal', 'lognorm', '[a, k]', 'k', k, {'> 0'});
                    else
                         a = 0;
                         k = 1;
                    end

                    out = exp( a + k * randn( sampleSize ) );

               case {'maxwell'}
                    % START maxwell HELP
                    % THE MAXWELL DISTRIBUTION
                    %
                    % pdf(y) = 1/a^3 * sqrt(2/pi) * y.^2 * exp(-y.^2/(2*a^2));  a > 0, y >= 0                    
                    % cdf(y) = gammainc(3/2, y.^2/(2*a^2));
                    %
                    % Mean     = 2*a*sqrt(2/pi);
                    % Variance = a^2*(3-8/pi);
                    % Skewness = 2*(16/pi-5)*sqrt(2/pi) / (3-8/pi)^(3/2) = 0.48569282804959
                    % Kurtosis = (15-8/pi)/(3-8/pi)^2 - 3 ???
                    %
                    % PARAMETERS:
                    %   a - scale parameter (a > 0)
                    %
                    % SUPPORT:
                    %   y, y >= 0
                    %
                    % CLASS:
                    %   Continuous skewed distribution                      
                    %
                    % NOTES:
                    %  The distribution of speeds of molecules in thermal equilibrium as given by
                    %  statistical mechanics and named after the famous scottish physicist James
                    %  Clerk Maxwell (1831-1879).
                    %
                    % USAGE:                 
                    %   randraw('maxwell', a, sampleSize) - generate sampleSize number
                    %         of variates from the Maxwell distribution with 
                    %         scale parameter 'a';
                    %   randraw('maxwell') - help for the Maxwell distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('maxwell', 1.1, [1 1e5]);
                    %  2.   y = randraw('maxwell', 0.5, 1, 1e5);
                    %  3.   y = randraw('maxwell', 10, 1e5 );
                    %  4.   y = randraw('maxwell', 5.5, [1e5 1] );
                    %  5.   randraw('maxwell');                       
                    % END maxwell HELP
                    
                    checkParamsNum(funcName, 'Maxwell', 'maxwell', distribParams, [1]);
                    a  = distribParams(1);
                    validateParam(funcName, 'Maxwell', 'maxwell', 'a', 'a', a, {'> 0'});

                    out = sqrt( randn(sampleSize).^2 + randn(sampleSize).^2 + ...
                         randn(sampleSize).^2 ) * a;

               case {'negativebinomial', 'negbinomial', 'negbinom', 'pascal'}
                    % START negbinom HELP START pascal HELP
                    % THE NEGATIVE BINOMIAL DISTRIBUTION
                    %  ( sometimes: Pascal distribution )
                    %
                    % Negative Binomial (also known as the Pascal or Polya) distribution
                    % gives the probability of r-1 successes and y failures in y+r-1 trials
                    % and success on the (y+r)'th trial (if r is positive integer )
                    %
                    %  pdf(y) = gamma(r+y)./(gamma(y+1)*gamma(r)) * p^r * (1-p)^y = ...
                    %           exp( gammaln(r+y) - gammaln(y+1) - gammaln(r) + r*log(p) + y*log(1-p) );
                    %              y>=0
                    %
                    %  Mode = (r>1)*floor( (r-1)*(1-p)/p ) + (r<=1)*0;
                    %  Mean = r*(1-p)/p;
                    %  Variance = r*(1-p)/p^2;
                    %  Skewness = (2-p) / sqrt(r*(1-p));
                    %  Kurtosis = (p^2-6*p+6)/(r*(1-p));
                    %
                    %  PARAMETERS: 
                    %      r>0; 
                    %      p - probability of success in a single trial ( 0< p <1 );
                    % 
                    %  SUPPORT: 
                    %      y = 0, 1, 2, 3, ...
                    %
                    % CLASS:
                    %   Discrete distribution  
                    %
                    % USAGE:                 
                    %   randraw('negbinom', [r, p], sampleSize) - generate sampleSize number
                    %         of variates from the Negative Binomial distribution with 
                    %        parameters 'r' and 'p';
                    %   randraw('negbinom') - help for the Negative Binomial distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('negbinom', [10 0.2], [1 1e5]);
                    %  2.   y = randraw('negbinom', [100, 0.9], 1, 1e5);
                    %  3.   y = randraw('negbinom', [20 0.1], 1e5 );
                    %  4.   y = randraw('negbinom', [30 0.99], [1e5 1] );
                    %  5.   randraw('negbinom');                       
                    % END negbinom HELP END pascal HELP
                    
                    % Method:
                    %
                    % We implemented Condensed Table-Lookup method suggested in
                    %    George Marsaglia, "Fast Generation Of Discrete Random Variables,"
                    %    Journal of Statistical Software, July 2004, Volume 11, Issue 4
                    
                    % pdf = exp( gammaln(r+y) - gammaln(y+1) - gammaln(r) + r*log(p) + y*log(1-p) );

                    checkParamsNum(funcName, 'Negative Binomial', 'negbinom', distribParams, [2]);                                        
                    r = distribParams(1);
                    validateParam(funcName, 'Negative Binomial', 'negbinom', '[r, p]', 'r', r, {'> 0'});
                    p = distribParams(2);
                    validateParam(funcName, 'Negative Binomial', 'negbinom', '[r, p]', 'p', p, {'> 0','< 1'});
                    
                    q = 1 - p;

                    if r*q/p^2 > 1e8
                         out = 1/p * feval(funcName, 'gamma', r*(1-p), sampleSize);
                    else
                         mode = (r>1)*floor( (r-1)*(1-p)/p ) + (r<=1)*0;
                         pmode = exp( gammaln(r+mode) - gammaln(mode+1) - gammaln(r) + ...
                              r*log(p) + mode*log(1-p) );

                         t=pmode;
                         ii = mode+1;
                         while t*2147483648 > 1
                              t = t * (r+ii-1)/ii * q;
                              ii = ii + 1;
                         end
                         last=ii-2;

                         t=pmode;
                         j=-1;
                         for ii=mode-1:-1:0
                              t = t * (ii+1)/(r+ii)/q;
                              if t*2147483648 < 1
                                   j=ii;
                                   break;
                              end
                         end
                         offset=j+1;
                         sizeP=last-offset+1;

                         P = zeros(1, sizeP);

                         ii = (mode+1):last;
                         P(mode-offset+1:last-offset+1) = round( 2^30*pmode*cumprod([1, (r+ii-1)./ii * q] ) );

                         ii = (mode-1):-1:offset;
                         P(mode-offset:-1:1) = round( 2^30*pmode*cumprod((ii+1)./(r+ii)/q) );

                         out = randFrom5Tbls( P, offset, sampleSize);                   
                    end
                    
               case {'normal', 'gaussian', 'gauss', 'norm'} % Gaussian distribution
                    % START normal HELP START gaussian HELP START gauss HELP START norm HELP
                    % THE NORMAL DISTRIBUTION
                    % Standard form of the Normal distribution:
                    %   pdf(y) = 1/sqrt(2*pi) * exp(-1/2*y.^2);
                    %   cdf(y) = 0.5*(1+erf(y/sqrt(2)));
                    %
                    % Mean = 0;
                    % Variance = 1;
                    %
                    % General form of the Normal distribution:
                    %   pdf(y) = 1/(sigma*sqrt(2*pi)) * exp(-1/2*((y-mu)/sigma).^2);
                    %   cdf(y) = 1/2*(1+erf((y-mu)/(sigma*sqrt(2))));
                    %
                    % Mean = mu;
                    % Variance = sigma^2;
                    %
                    % PARAMETERS:
                    %  mu      - location (mean)
                    %  sigma>0 - scale (std)
                    %
                    % SUPPORT:
                    %  y,   -Inf < y < Inf
                    %
                    % CLASS:
                    %   Continuous symmetric distributions
                    %
                    % USAGE:
                    %   randraw('norm', [], sampleSize) - generate sampleSize number
                    %         of variates from the standard Normal distribution;                  
                    %   randraw('norm', [a, k], sampleSize) - generate sampleSize number
                    %         of variates from the Normal distribution with 
                    %         mean 'mu' and std 'sigma';
                    %   randraw('norm') - help for the Lognormal distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('norm', [], [1 1e5]);
                    %  2.   y = randraw('norm', [0, 4], 1, 1e5);
                    %  3.   y = randraw('norm', [-1, 10.2], 1e5 );
                    %  4.   y = randraw('norm', [3.2, 0.3], [1e5 1] );
                    %  5.   randraw('norm');    
                    % END normal HELP END gaussian HELP END gauss HELP END norm HELP
                    
                    checkParamsNum(funcName, 'Normal', 'normal', distribParams, [0, 2]);
                    
                    if numel(distribParams)==2
                         mu = distribParams(1);
                         sigma = distribParams(2);
                         validateParam(funcName, 'Normal', 'normal', '[mu, sigma]', 'sigma', sigma, {'> 0'});
                    else
                         mu = 0;
                         sigma = 1;
                    end

                    out = mu + sigma * randn( sampleSize );

               case {'normaltrunc', 'normaltruncated', 'gausstrunc'}
                    % START normaltrunc HELP START normaltruncated HELP START gausstrunc HELP
                    % THE TRUNCATED NORMAL DISTRIBUTION
                    %
                    %   pdf(y) = normpdf((y-mu)/sigma) / (sigma*(normcdf((b-mu)/sigma)-normcdf((a-mu)/sigma))); a<=y<=b; 
                    %   cdf(y) = (normcdf((y-mu)/sigma)-normcdf((a-mu)/sigma)) / (normcdf((b-mu)/sigma)-normcdf((a-mu)/sigma)); a<=y<=b;
                    %      where mu and sigma are the mean and standard deviation of the parent normal 
                    %            distribution and a and b are the lower and upper truncation points. 
                    %            normpdf and normcdf are the PDF and CDF for the standard normal distribution respectvely
                    %            ( run randraw('normal') for help).
                    %                                        
                    %
                    % PARAMETERS:  
                    %   a  - lower truncation point;
                    %   b  - upper truncation point; (b>=a)
                    %   mu - Mean of the parent normal distribution
                    %   sigma - standard deviation of the parent normal distribution (sigma>0)
                    %   
                    %
                    % SUPPORT:      
                    %   y,   a <= y <= b
                    %
                    % CLASS:
                    %   Continuous distributions
                    %
                    % USAGE:
                    %   randraw('normaltrunc', [a, b, mu, sigma], sampleSize) - generate sampleSize number
                    %         of variates from Truncated Normal distribution on the interval (a, b) with
                    %         parameters 'mu' and  'sigma';
                    %   randraw('normaltrunc') - help for Truncated Normal distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('normaltrunc', [0, 1, 0, 1], [1 1e5]);
                    %  2.   y = randraw('normaltrunc', [0, 1, 10, 3], 1, 1e5);
                    %  3.   y = randraw('normaltrunc', [-10, 10, 0, 1], 1e5 );
                    %  4.   y = randraw('normaltrunc', [-13.1, 15.2, 20.1, 3.3], [1e5 1] );
                    %  5.   randraw('normaltrunc');                    
                    % END normaltrunc HELP END normaltruncated HELP END gausstrunc HELP
                    
                    checkParamsNum(funcName, 'Truncated Normal', 'normaltrunc', distribParams, [4]);
                    
                    a = distribParams(1);
                    b = distribParams(2);
                    mu = distribParams(3);
                    sigma = distribParams(4);
                    validateParam(funcName, 'Truncated Normal', 'normaltrunc', '[a, b, mu, sigma]', 'b-a', b-a, {'>=0'});
                    validateParam(funcName, 'Truncated Normal', 'normaltrunc', '[a, b, mu, sigma]', 'sigma', sigma, {'> 0'});

                    PHIl = normcdf((a-mu)/sigma);
                    PHIr = normcdf((b-mu)/sigma);
                    
                    out = mu + sigma*( sqrt(2)*erfinv(2*(PHIl+(PHIr-PHIl)*rand(sampleSize))-1) );
                    
               case {'nig'}
                    % START nig HELP
                    % THE NORMAL INVERSE GAUSSIAN (NIG) DISTRIBUTION 
                    %  NIG(alpha, beta, mu, delta)
                    %
                    %  Heavy-tailed distributions such as the normal inverse Gauss distribution
                    %  (NIG) play a prominent role in the statistical analysis of economic time-series.
                    %  A number of empirical studies have shown that the marginal distribution of the
                    %  daily returns of liquid shares are NIG. 
                    %
                    %   The NIG density is a variance-mean mixture of a Gaussian density with 
                    %  an inverse Gaussian.                    
                    %   The shape of the NIG density is specified by the four-dimensional 
                    %  parameter vector [alpha, beta , mu, delta]. The rich parametrization
                    %  makes the NIG density a suitable model for a variety of unimodal positive 
                    %  kurtotic data. The alpha-parameter controls the steepness or pointiness 
                    %  of the density, which increases monotonically with increasing alpha.
                    %  A large alpha implies light tails, a small value implies heavy tails.
                    %  The beta-parameter controls the skewness. For beta<0, the density is skewed to
                    %  the left, for beta>0 the density is skewed to the right, while
                    %  beta=0 implies a symmetric density around mu, which is a centrality parameter.
                    %  The delta-parameter is a scale-like parameter.
                    %
                    %  pdf(y; alpha, beta, mu, delta) = ...
                    %      alpha/pi * exp(delta*sqrt(alpha^2-beta^2) - beta*mu) * ...
                    %      1/sqrt(1+((y-mu)/delta).^2) .* ...
                    %      besselk(1, alpha*delta*sqrt(1+((y-mu)/delta).^2)) .*...
                    %      exp(beta*y);
                    %
                    %   Mean = mu+beta*delta/sqrt(alpha^2-beta^2);
                    %   Variance = delta * (alpha^2 / sqrt(alpha^2 - beta^2)^3);
                    %   Skewness = 3*beta/(alpha*sqrt(delta*sqrt(alpha^2 - beta^2)));
                    %   Kurtosis = 3*(1 + 4*(beta/alpha)^2)/(delta*sqrt(alpha^2 - beta^2));
                    %
                    %  PARAMETERS:
                    %    alpha,  alpha > 0
                    %    beta,   0 <= abs(beta) < alpha
                    %    mu,     -Inf < mu < Inf
                    %    delta,  delta > 0 
                    %
                    %  SUPPORT:      
                    %    y,   -Inf < y < Inf
                    %
                    % CLASS:
                    %   Continuous skewed distribution
                    %
                    % USAGE:
                    %   randraw('nig', [alpha, beta, mu, delta], sampleSize) - generate sampleSize
                    %         number of variates from NIG distribution with parameters
                    %         alpha, beta, mu and delta                    
                    %   randraw('nig') - help for NIG distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('nig', [2, 1, 4, 2], [1 1e5]);
                    %  2.   y = randraw('nig', [2, 1, 4, 2], 1, 1e5);
                    %  3.   y = randraw('nig', [2, 1, 4, 2], 1e5 );
                    %  4.   y = randraw('nig', [2, 1, 4, 2], [1e5 1] );
                    %  5.   randraw('nig');
                    %
                    % SEE ALSO:
                    %  INVERSE GAUSSIAN distribution                    
                    % END nig HELP
                    
                    % REFERENCES:
                    % 1. http://www.quantlet.com/mdstat/scripts/csa/html/node236.html
                    % 2. http://www.anst.uu.se/larsfors/APRv1_5.pdf
                    % 3. http://ica2001.ucsd.edu/index_files/pdfs/048-jenssen.pdf  
                    % 4. http://www.freidok.uni-freiburg.de/volltexte/15/pdf/15_1.pdf

                    
                    checkParamsNum(funcName, 'NIG', 'nig', distribParams, [4]);
                                        
                    alpha = distribParams(1);
                    beta  = distribParams(2);
                    mu    = distribParams(3);
                    delta = distribParams(4);
                    
                    validateParam(funcName, 'NIG', 'nig', '[alpha, beta, mu, delta]', 'alpha', alpha, {'> 0'});
                    validateParam(funcName, 'NIG', 'nig', '[alpha, beta, mu, delta]', 'delta', delta, {'> 0'});
                    validateParam(funcName, 'NIG', 'nig', '[alpha, beta, mu, delta]', 'alpha-abs(beta)', alpha-abs(beta), {'> 0'});
                    
                    invGaussY = feval(funcName, 'ig', [delta/sqrt(alpha^2-beta^2), delta^2], sampleSize);
                    out = mu + beta*invGaussY + sqrt(invGaussY).*randn(sampleSize);
                    
               case {'pareto'}
                    % START pareto HELP
                    %   Pareto or "power law" distribution, used in the analysis of financial data
                    %   and critical behavior
                    %
                    %  pdf = a*k^a ./ y.^(a+1);
                    %  cdf = 1 - (k./y).^a;
                    %
                    %  Mean = k*a/(a-1);
                    %  Variance = k^2*a/((a-2)*(a-1)^2);
                    %  Skewness = 2*(a+1)*sqrt(a-2)/((a-3)*sqrt(a));
                    %  Kurtosis = 6*(a^3+a^2-6*a-2)/(a*(a^2-7*a+12));
                    %
                    % PARAMETERS:
                    %  k - location parameter  (k>0)
                    %  a - shape parameter (a>0)                    
                    %
                    % SUPPORT:
                    %  y,  y > k
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('pareto', [k, a], sampleSize) - generate sampleSize
                    %         number of variates from the Pareto distribution with parameters
                    %         'k' and 'a'                    
                    %   randraw('pareto') - help for the Pareto distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('pareto', [1, 2], [1 1e5]);
                    %  2.   y = randraw('pareto', [3, 8], 1, 1e5);
                    %  3.   y = randraw('pareto', [0.5, 2.4], 1e5 );
                    %  4.   y = randraw('pareto', [3.5, 4.5], [1e5 1] );
                    %  5.   randraw('pareto');                     
                    % END pareto HELP

                    checkParamsNum(funcName, 'Pareto', 'pareto', distribParams, [2]);
                                        
                    k = distribParams(1);
                    a  = distribParams(2);
                    validateParam(funcName, 'Pareto', 'pareto', '[k, a]', 'k', k, {'> 0'});
                    validateParam(funcName, 'Pareto', 'pareto', '[k, a]', 'a', a, {'> 0'});

                    out = k*rand( sampleSize ).^(-1/a);

               case {'pareto2', 'lomax'}
                    % START pareto2 HELP
                    % THE PARETO DISTRIBUTION OF THE SECOND TYPE
                    %  (sometimes Lomax distribution )
                    %
                    %  pdf = b*k^b ./ (k+y).^(b+1);   b>0, y>0;
                    %  cdf = 1 - k^b./(k+y).^b; 
                    %
                    % PARAMETERS:
                    %   k - location parameters (k>0)
                    %   b - shape parameters (b>0)
                    %
                    % SUPPORT:
                    %   y,  y>0
                    %
                    % CLASS;
                    %  Continuous skewed distribution
                    %
                    % USAGE:
                    %   randraw('pareto2', [k, b], sampleSize) - generate sampleSize
                    %         number of variates from the Pareto Second Type distribution with parameters
                    %         'k' and 'b'                    
                    %   randraw('pareto2') - help for the Pareto Second Type distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('pareto2', [1, 2], [1 1e5]);
                    %  2.   y = randraw('pareto2', [3, 8], 1, 1e5);
                    %  3.   y = randraw('pareto2', [0.5, 2.4], 1e5 );
                    %  4.   y = randraw('pareto2', [3.5, 4.5], [1e5 1] );
                    %  5.   randraw('pareto2');
                    % END pareto2 HELP
                    
                    checkParamsNum(funcName, 'Pareto Second Type', 'pareto2', distribParams, [2]);
                    
                    k = distribParams(1);
                    b  = distribParams(2);
                    validateParam(funcName, 'Pareto Second Type', 'pareto2', '[k, b]', 'k', k, {'> 0'});
                    validateParam(funcName, 'Pareto Second Type', 'pareto2', '[k, b]', 'b', b, {'> 0'});
                    
                    out = k*(1 - rand( sampleSize )).^(-1/b) - k;
                    
               case 'planck'
                    % START planck HELP
                    % THE PLANCK DISTRIBUTION
                    % The Planck distribution widely used in Physics.
                    %
                    % The Planck distribution ia a two parameter distribution:
                    % pdf(y) = b^(a+1)/(gamma(a+1)*zeta(a+1)) * y^a/(exp(b*y)-1);
                    %    where zeta(c) is the Riemann zeta function defined as
                    %       zeta(c) = sum from k=1 to Inf of 1/k^c.
                    % 
                    % PARAMETERS:
                    %  a > 0 is a shape parameter
                    %  b > 0 is a scale parameter
                    %
                    % SUPPORT:
                    %  y, y>0
                    %
                    % CLASS:
                    %  Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('planck', [a, b], sampleSize) - generate sampleSize
                    %         number of variates from the Planck distribution with parameters
                    %         'a' and 'b'                    
                    %   randraw('planck') - help for the Planck distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('planck', [1, 2], [1 1e5]);
                    %  2.   y = randraw('planck', [3, 8], 1, 1e5);
                    %  3.   y = randraw('planck', [0.5, 2.4], 1e5 );
                    %  4.   y = randraw('planck', [3.5, 4.5], [1e5 1] );
                    %  5.   randraw('planck');                           
                    % END planck HELP
                    
                    % Reference:
                    % Luc Devroye, "Non-Uniform Random Variate Generation,"
                    % Springer 1986, 850p. 3-540-96305-7

                    checkParamsNum(funcName, 'Planck', 'planck', distribParams, [2]);
                    

                    a = distribParams(1);
                    b  = distribParams(2);
                    validateParam(funcName, 'Planck', 'planck', '[a, b]', 'a', a, {'> 0'});
                    validateParam(funcName, 'Planck', 'planck', '[a, b]', 'b', b, {'> 0'});

                    zetav = feval(funcName, 'zeta', a+1, sampleSize);
                    out = feval(funcName, 'gamma', a+1, sampleSize) ./ ...
                         (b * zetav);

               case {'poisson', 'po'}
                    % START po HELP START poisson HELP
                    % THE POISSON DISTRIBUTION
                    %    ~ Poisson(lambda)
                    %
                    % pdf(y) = exp(-lambda)*lambda^y/factorial(y) = ...
                    %           exp( -lambda + y*log(lambda) - gammaln(y+1) ); lambda>0
                    %
                    %  Mean = lambda;
                    %  Variance = lambda
                    %  Mode = floor(lambda);
                    %
                    % PARAMETERS:
                    %  lambda,  lambda > 0
                    %
                    % SUPPORT:
                    %  y,  y = 0, 1, 2, 3, 4, ...
                    %
                    % CLASS:
                    %  Discrete distributions
                    %
                    % NOTES:
                    %  1. If lambda is an integer, Mode also equals (lambda+1).
                    %  2. The Poisson distribution is commonly used as an approximation 
                    %     to the Binomial distribution when probability of success is very small.
                    %  3. In queueing theory, when interarrival times are ~Exponential, the number of arrivals in a
                    %     fixed interval are ~Poisson.
                    %  4. Errors in observations with integer values (i.e., miscounting) are ~Poisson.
                    %
                    % USAGE:
                    %   randraw('po', lambda, sampleSize) - generate sampleSize
                    %         number of variates from the Poisson distribution with 
                    %         parameter lambda;
                    %   randraw('po') - help for the Poisson distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('po', [2], [1 1e5]);
                    %  2.   y = randraw('po', [3], 1, 1e5);
                    %  3.   y = randraw('po', [10.4], 1e5 );
                    %  4.   y = randraw('po', [100.25], [1e5 1] );
                    %  5.   randraw('po');
                    %
                    % SEE ALSO:
                    %  BINOMIAL distribution                    
                    %
                    % END po HELP END poisson HELP
                    
                    % Method:
                    % 1) If lambda > 1000 we use normal approximation to poisson distribution
                    %      mean=lambda, variance=lambda^2
                    % 2) If lambda < 1000 we use the following reference:
                    %    George Marsaglia, Fast Generation Of Discrete Random Variables,
                    %    Journal of Statistical Software, July 2004, Volume 11, Issue 4
                    %
                    %    (Note: this method does not support lambda<5e-10.
                    %          So for lambda<5e-10 we return 0 )

                    if numel(distribParams) ~= 1
                         error('Poisson Distribution: Wrong numebr of parameters (run randraw(''poisson'') for help) ');
                    end
                    lam = distribParams(1);
                    if lam < 0
                         error('Poisson Distribution: Parameter ''lambda'' should be positive (run randraw(''poisson'') for help) ');
                    end

                    if lam > 1e3
                         % For sufficiently large values of lambda (lambda > 1000 say),
                         % the normal distribution with mean lambda and variance lambda is
                         % an excellent approximation to the Poisson distribution.

                         out = round( lam + sqrt(lam) * randn( sampleSize ) );

                    else % lam <= 1e3

                         if lam<21.4
                              if lam<5e-10
                                   varargout{1} = zeros( sampleSize );
                                   return;
                              end
                              t=exp(-lam);
                              p = t;
                              ii = 1;
                              while t*2147483648 > 1
                                   t = t * (lam/ii);
                                   ii = ii + 1;
                              end
                              sizeP = ii-1;
                              offset = 0;
                              %/* Given size, fill P array (30-bit integers) */

                              P = round( 2^30*p*cumprod([1, lam./(1:sizeP-1)] ) );
                         else %lam>21.4

                              % maximum lam = 1940;

                              mode = floor(lam);
                              
                              loglam = log(lam);
                              log2147483648 = log(2147483648);
                              tmode = -lam + mode*loglam - gammaln(mode+1);
                              pmode = exp( tmode );

                              t = tmode;
                              ii = mode + 1;
                              while t + log2147483648 > 0
                                   t = t + loglam - log(ii);
                                   ii = ii + 1;
                              end                                   
                              last = ii-2;
                              
                              t = tmode;
                              j=-1;
                              for ii=mode-1:-1:0
                                   t = t - loglam + log(ii+1);
                                   if t + log2147483648 < 0
                                        j=ii;
                                        break;
                                   end
                              end
                    
                              offset = j+1;
                              sizeP = last-offset+1;

                              P = zeros(1, sizeP);
                     
                              ii = (mode+1):last;
                              P(mode-offset+1:last-offset+1) = round( 2^30*pmode*cumprod([1, lam./ii]) );
                             
                              ii = (mode-1):-1:offset;
                              P(mode-offset:-1:1) = round( 2^30*pmode*cumprod((ii+1)/lam) );

                         end


                         out = randFrom5Tbls( P, offset, sampleSize);
                         
                    end
                    
               case {'quadratic', 'quad', 'quadr'}
                    % START quadratic HELP  START quad HELP START quadr HELP
                    % THE QUADRATIC DISTRIBUTION
                    %
                    % Standard form of the quadratic distribution:
                    %
                    %   pdf(y) = 3/4*(1-y.^2); -1<=y<=1;
                    %
                    %  Mean = 0;
                    %  Variance = 1/5;
                    %
                    % General form of the quadratic distribution:
                    %
                    %   pdf(y) = 3/(4*s) * (1-((y-t)/s).^2); t-s<=y<=t+s; s>0
                    %   cdf(y) = 1/2 + 3/4*(y-t)/s - 1/4*((y-t)/s).^3; ; t-s<=y<=t+s; s>0
                    %
                    %  Mean = t;
                    %  Variance = s^2/5;
                    %
                    % PARAMETERS:  
                    %   t - location
                    %   s -scale; s>0
                    %
                    % SUPPORT:      
                    %   y,   -1 <= y <= 1   - standard Quadratic distribution
                    %    or
                    %   y,   t-s <= y <= t+s  - generalized Quadratic distribution
                    %
                    % CLASS:
                    %   Continuous distributions
                    %
                    % USAGE:
                    %   randraw('quadr', [], sampleSize) - generate sampleSize number
                    %         of variates from standard Quadratic distribution;
                    %   randraw('quadr', [t, s], sampleSize) - generate sampleSize number
                    %         of variates from generalized Quadratic distribution
                    %         with location parameter 't' and scale parameter 's';
                    %   randraw('quadr') - help for Quadratic distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('quadr', [], [1 1e5]);
                    %  2.   y = randraw('quadr', [], 1, 1e5);
                    %  3.   y = randraw('quadr', [], 1e5 );
                    %  4.   y = randraw('quadr', [10 3], [1e5 1] );
                    %  5.   randraw('quadr');                   
                    % END quadratic HELP END quad HELP END quadr HELP
                    
                    
                    % Method:
                    %
                    % Inverse CDF transformation method.
                    % We use Vi`ete formula to solve cubic equation.
                    
                    checkParamsNum(funcName, 'Quadratic', 'quadratic', distribParams, [0, 2]);  
                    if numel(distribParams)==2
                         t  = distribParams(1);
                         s  = distribParams(2);  
                         validateParam(funcName, 'Quadratic', 'quadratic', '[t, s]', 's', s, {'> 0'});
                    else
                         t = 0;
                         s = 1;                        
                    end                      
                    
                    out = t + s * 2*sin(1/3*asin(2*rand( sampleSize )-1));
                                                         
               case {'rademacher'}
                    % START rademacher HELP
                    % THE RADEMACHER DISTRIBUTION
                    %   The Rademacher distribution takes value 1 with probability 1/2
                    %   and value -1 with probability 1/2 (it is simply a random sign)
                    %   ( Hans Rademacher (1892-1969) )
                    %
                    % PARAMETERS:
                    %    None
                    %
                    % SUPPORT:
                    %   y = -1 or 1
                    %
                    % CLASS:
                    %   Descrete distributions
                    %
                    % USAGE:
                    %   randraw('rademacher', [], sampleSize) - generate sampleSize number
                    %         of variates from the Rademacher distribution;
                    %   randraw('rademacher') - help for the Rademacher distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('rademacher', [], [1 1e5]);
                    %  2.   y = randraw('rademacher', [], 1, 1e5);
                    %  3.   y = randraw('rademacher', [], 1e5 );
                    %  4.   y = randraw('rademacher', [], [1e5 1] );
                    %  5.   randraw('rademacher');  
                    % END rademacher HELP

                    checkParamsNum(funcName, 'Rademacher', 'rademacher', distribParams, [0]); 
                    
                    out = 2*round(rand(sampleSize)) - 1;

               case {'rayl', 'rayleigh'}
                    % START rayl HELP START rayleigh HELP
                    % THE RAYLEIGH DISTRIBUTION
                    %
                    %  pdf  = y./sigma^2 * exp(-y.^2/(2*sigma^2)); y >= 0
                    %  cdf  = 1 - exp(-y.^2/(2*sigma^2));
                    %
                    %  Mean = sqrt(pi/2)*sigma;
                    %  Variance = (4-pi)/2*sigma^2;
                    %
                    % PARAMETERS:
                    %   sigma - scale parameter (-Inf < sigma < Inf)
                    %
                    % SUPPORT:
                    %   y,  y >= 0 
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    %  USAGE:
                    %   randraw('rayl', sigma, sampleSize) - generate sampleSize number
                    %         of variates from the Rayleigh distribution with scale parameter 'sigma';
                    %   randraw('rayl') - help for the Rayleigh distribution;
                    %
                    %  EXAMPLES:
                    %   1.   y = randraw('rayl', 1, [1 1e5]);
                    %   2.   y = randraw('rayl', 2.5, 1, 1e5);
                    %   3.   y = randraw('rayl', 3, 1e5 );
                    %   4.   y = randraw('rayl', 4, [1e5 1] );
                    %   5.   randraw('rayl'); 
                    %
                    %  SEE ALSO:
                    %    CHI, MAXWELL, WEIBULL distributions
                    % END rayl HELP END rayleigh HELP

                    checkParamsNum(funcName, 'Rayleigh', 'rayl', distribParams, [1]);
                    sigma = distribParams(1);
                    
                    out = sqrt(-2 * sigma^2 * log(rand( sampleSize ) ));

               case {'semicirc', 'semicircle', 'wigner'}
                    % START semicirc HELP START semicircle HELP START wigner HELP
                    % THE SEMICIRCLE DISTRIBUTION
                    %   ( Wigner semicircle distribution)
                    %
                    % The Wigner semicircle distribution, named after the physicist Eugene Wigner, 
                    % is the probability distribution supported on the interval [m?R, m+R] the graph 
                    % of whose probability density function is a semicircle of radius R centered at 
                    % (m, 0) and then suitably normalized (so that it is really a semi-ellipse).
                    %
                    %  pdf = 2/(pi*R^2) * sqrt(1-(y-m).^2);
                    %
                    %  Mean = m;
                    %  Variance = R^2/4;
                    %
                    %  PARAMETERS:
                    %    m - location;
                    %    R - semicircle radius; (R>0)
                    %
                    %  SUPPORT:
                    %    y,  m-R <= y <= m+R
                    %
                    %  CLASS:
                    %    Continuous symmetric distributions
                    %
                    %  USAGE:
                    %   randraw('semicirc', [m, R], sampleSize) - generate sampleSize number
                    %         of variates from the Semicircle distribution on the interval [m-R, m+R];
                    %   randraw('semicirc') - help for the Semicircle distribution;
                    %
                    %  EXAMPLES:
                    %   1.   y = randraw('semicirc', [0, 1], [1 1e5]);
                    %   2.   y = randraw('semicirc', [-1.5, 5], 1, 1e5);
                    %   3.   y = randraw('semicirc', [2, 10], 1e5 );
                    %   4.   y = randraw('semicirc', [11, 1], [1e5 1] );
                    %   5.   randraw('semicirc');                     
                    % END semicirc HELP END semicircle HELP END wigner HELP

                    checkParamsNum(funcName, 'Semicircle', 'semicirc', distribParams, [2]);
                    m = distribParams(1);
                    R = distribParams(2);
                    validateParam(funcName, 'Semicircle', 'semicirc', '[m, R]', 'R', R, {'> 0'});                                                  
                    
                    out = m + R*sqrt(rand(sampleSize)) .* cos( rand(sampleSize)*pi );

               case {'skellam'}
                    % START skellam HELP
                    % THE SKELLAM DISTRIBUTION
                    %
                    %  The Skellam distribution is the probability distribution of the difference N1 - N2
                    %  of two uncorrelated random variables N1 and N2 having Poisson distributions
                    %  with different expected values lambda1 and lambda2.
                    %  The Skellam probability density function is:
                    %
                    %    pdf(n) = exp(-lambda1+lambda2)*(lambda1/lambda2)^(n/2)*besseli(n,2*sqrt(lambda1*lambda2));
                    %     where besseli is the modified Bessel function of the first kind.
                    % 
                    %  Mean = lambda1 - lambda2;
                    %  Variance = lambda1 + lambda2;
                    %  Kurtosis = 1/(lambda1 + lambda2);
                    %  Skewness = (lambda1 - lambda2)/(lambda1 + lambda2)^(3/2);
                    %
                    % PARAMETERS:
                    %   lambda1 >= 0;
                    %   lambda2 >= 0;
                    %
                    % SUPPORT:
                    %   n = ..., -2, -1, 0, 1, 2, 3 ...
                    %
                    % CLASS:
                    %   Discrete distributions
                    %
                    % USAGE:
                    %   randraw('skellam', [lambda1, lambda2], sampleSize) - generate sampleSize number
                    %         of variates from the Skellam distribution with parameters
                    %         lambda1 and lambda2;                   
                    %   randraw('skellam') - help for the Skellam distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('skellam', [1, 2], [1 1e5]);
                    %  2.   y = randraw('skellam', [3, 3], 1, 1e5);
                    %  3.   y = randraw('skellam', [5, 6], 1e5 );
                    %  4.   y = randraw('skellam', [1.5, 5.6], [1e5 1] );
                    %  5.   randraw('skellam');     
                    %
                    % SEE ALSO:
                    %   Poisson Distribution ( randraw('po') );                    
                    % END skellam HELP


                    checkParamsNum(funcName, 'Skellam', 'skellam', distribParams, [2]);
                    lambda1 = distribParams(1);
                    lambda2 = distribParams(2);
                    validateParam(funcName, 'Skellam', 'skellam', '[lambda1, lambda2]', 'lambda1', lambda1, {'> 0'});                                                  
                    validateParam(funcName, 'Skellam', 'skellam', '[lambda1, lambda2]', 'lambda2', lambda2, {'> 0'});    
                    
                    poiss1 = feval(funcName,'poisson',lambda1, sampleSize);
                    out    = feval(funcName,'poisson',lambda2, sampleSize);

                    out = poiss1 - out;

               case {'studentst', 't'} 
                    % START studentst HELP START t HELP 
                    % THE STUDENT'S-T DISTRIBUTION
                    %    ( t-distribution )
                    %
                    %  Standard form of Student's-t distribution:
                    %
                    %   pdf = gamma((nu+1)/2)/(sqrt(nu*pi)*gamma(nu/2)) *(1+y.^2/nu)^(-(nu+1)/2);
                    %        or alternatively:
                    %   pdf = (1+y.^2/nu)^(-(nu+1)/2) / (sqrt(nu)*beta(1/2,nu/2));
                    %
                    %   cdf = 1/2 + ( -(y<0) + (y>=0) ) .* ...
                    %          1/2*betainc( y.^2./(nu+y.^2), 1/2, nu/2 );
                    %
                    %  Mean = 0; 
                    %  Variance = nu/(nu-2);
                    %  Skewness = 0;
                    %  Kurtosis = 3*( (nu-2)^2*gamma(nu/2-2)/(4*gamma(nu/2)) - 1 );
                    %
                    %  General form of Student's-t distribution:
                    %
                    %   pdf = gamma((nu+1)/2)/(sqrt(nu*pi)*gamma(nu/2)) *(1+((y-chi)/eta).^2/nu)^(-(nu+1)/2);
                    %        or alternatively:
                    %   pdf = (1+((y-chi)/eta).^2/nu)^(-(nu+1)/2) / (sqrt(nu)*beta(1/2,nu/2));
                    %
                    %   cdf = 1/2 + ( -(y<chi) + (y>=chi) ) .* ...
                    %          1/2*betainc( ((y-chi)/eta).^2./(nu+((y-chi)/eta).^2), 1/2, nu/2 );
                    %
                    %  Mean = chi;
                    %  Variance = nu/(nu-2)*eta^2;  (nu>2)
                    %  Skewness = 0;
                    %  Kurtosis = 3*( (nu-2)^2*gamma(nu/2-2)/(4*gamma(nu/2)) - 1 );
                    %
                    % PARAMETERS:
                    %   nu - degrees of freedom (nu = 1, 2, 3, ...)
                    %   chi - location parameter
                    %   eta - scale parameter ( eta > 0 )
                    %
                    %  SUPPORT:
                    %   y , -Inf < y < Inf
                    %
                    %  CLASS:
                    %   Continuous symmetric distributions
                    %
                    % USAGE:
                    %   randraw('t', nu, sampleSize) - generate sampleSize number
                    %         of variates from the standard Student's t-distribution with degrees of
                    %         freedom 'nu'
                    %   randraw('t', [nu, chi, eta], sampleSize) - generate sampleSize number
                    %         of variates from the generalized Student's t-distribution with degrees of
                    %         freedom 'nu', location 'chi' and scale parameter 'eta'                    
                    %   randraw('t') - help for the Student's t-distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('t', 3, [1 1e5]);
                    %  2.   y = randraw('t', [4, -10, 3], 1, 1e5);
                    %  3.   y = randraw('t', [5, 6.5, 10.5], 1e5 );
                    %  4.   y = randraw('t', [6, 7, 8], [1e5 1] );
                    %  5.   randraw('t');                      
                    % END studentst HELP END t HELP 
                    
                    % Method:
                    %
                    % If nu<=100 we utilize the following transformation:
                    %
                    % Y = X/sqrt(Z/nu) ~ Student's-t(nu),
                    % where X~Normal(0,1) and Z~Chi^2(nu);
                    %
                    % Else, we use Normal(0, 1) instead of Student's-t
                    %
                    
                    checkParamsNum(funcName, 'Student''s'' t', 't', distribParams, [1 3]);
                    if numel(distribParams)==3
                         nu = distribParams(1);
                         chi = distribParams(2);
                         eta = distribParams(3);
                         validateParam(funcName, 'Student''s'' t', 't', '[nu, chi, eta]', 'nu', nu, {'> 0','==integer'});                                                  
                         validateParam(funcName, 'Student''s'' t', 't', '[nu, chi, eta]', 'eta', eta, {'> 0'});
                    else
                         nu = distribParams(1);
                         validateParam(funcName, 'Student''s'' t', 't', 'nu', 'nu', nu, {'> 0','==integer'});                                                                           
                         chi = 0;
                         eta = 1;                         
                    end
                    

                    if nu <= 100
                         chisq = feval(funcName, 'chisq', nu, sampleSize);
                         out = chi + eta * sqrt(nu)*randn( sampleSize ) ./ sqrt( chisq );
                    else
                         out = chi + eta * randn( sampleSize );
                    end

               case {'tri', 'triangular'}
                    % START tri HELP START triangular HELP
                    % THE TRIANGULAR DISTRIBUTION
                    %
                    %  pdf  = (a <= y & y <= c) .* ( 2*(y-a)/((b-a)*(c-a)) ) + ...
                    %           (c <  y & y <= b) .* ( 2*(b-y)/((b-a)*(b-c)) ) + ...
                    %            (y < a | y > b) .* 0;
                    %
                    %  cdf =  ( y < a ) .* 0 + ... 
                    %           (a <= y & y <= c) .* ( (y-a).^2/((b-a)*(c-a)) ) + ...
                    %           (c <  y & y <= b) .* ( 1- (b-y).^2/((b-a)*(b-c)) ) + ...
                    %            (y > b) .* 1;
                    %
                    %  Mean = 1/3*(a+b+c);
                    %  Variance = 1/18*(a^2+b^2+c^2-a*b-a*c-b*c);
                    %  Skewness = sqrt(2)*(a+b-2*c)*(2*a-b-c)*(a-2*b+c) / (5*(a^2+b^2+c^2-a*b-a*c-b*c)^(3/2));
                    %  Kurtosis = -3/5;
                    %
                    %  PARAMETERS:
                    %    a - lower bound
                    %    c - mode (c>a)
                    %    b - upper bound (b>c>a)
                    %
                    %  SUPPORT:
                    %   y, a <= y <= c
                    %
                    %  CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('tri', [a, c, b], sampleSize) - generate sampleSize number
                    %         of variates from the Triangular distribution with parameters
                    %         'a', 'c' and 'b';
                    %   randraw('tri') - help for the Triangular distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('tri', [0, 1, 2], [1 1e5]);
                    %  2.   y = randraw('tri', [1, 10, 20], 1, 1e5);
                    %  3.   y = randraw('tri', [0.5, 5, 10.5], 1e5 );
                    %  4.   y = randraw('tri', [2.4, 3.4, 5.4], [1e5 1] );
                    %  5.   randraw('tri');  
                    % END tri HELP END triangular HELP

                    checkParamsNum(funcName, 'Triangular', 'tri', distribParams, [3]);
                    a = distribParams(1);
                    c = distribParams(2);
                    b = distribParams(3);
                    validateParam(funcName, 'Triangular', 'tri', '[a, b, c]', 'c-a', c-a, {'> 0'});
                    validateParam(funcName, 'Triangular', 'tri', '[a, b, c]', 'b-c', b-c, {'> 0'});
                    validateParam(funcName, 'Triangular', 'tri', '[a, b, c]', 'b-a', b-a, {'> 0'});
                    
                    t = (c-a) / (b-a);
                    u1 = rand( sampleSize );
                    out = a + (b-a) * ...
                         ((u1 <= t) .* sqrt( t*u1 ) + (u1 > t) .* ( 1 - sqrt((1-t)*(1-u1)) ));

               case {'tukeylambda'}
                    % START tukeylambda HELP
                    % THE TUKEY-LAMBDA DISTRIBUTION
                    %
                    % The Tukey-Lambda Distribution with shape parameter lambda.
                    %
                    % The Tukey-Lambda distribution does not have a simple closed form 
                    % for either the probability density function or the cumulative
                    % distribution function. The cumulative distribution function is 
                    % calculated numerically. Some special cases are:
                    % lambda = -1 - approximately Cauchy;
                    % lambda = 0 - exactly logistic;
                    % lambda = 0.14 - approximately normal;
                    % lambda = 0.5 - U-shaped;
                    % lambda= 1 - exactly uniform.
                    %
                    % PARAMETERS:
                    %    lambda - shape parameter
                    %
                    % SUPPORT: 
                    %    y,   -1/lambdal <= y <= 1/lambda
                    %
                    % CLASS:
                    %   Continuous symmetric distributions
                    %
                    % USAGE:
                    %   randraw('tukeylambda', lambda, sampleSize) - generate sampleSize number
                    %         of variates from the Tukey-Lambda distribution with shale parameter 
                    %         'lambda';
                    %   randraw('tukeylambda') - help for the Tukey-Lambda distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('tukeylambda', -1, [1 1e5]);
                    %  2.   y = randraw('tukeylambda', 0, 1, 1e5);
                    %  3.   y = randraw('tukeylambda', 0.14, 1e5 );
                    %  4.   y = randraw('tukeylambda', 0.5, [1e5 1] );
                    %  5.   randraw('tukeylambda');                                 
                    % END tukeylambda HELP
                    
                    checkParamsNum(funcName, 'Tukey-Lambda', 'tukeylambda', distribParams, [1]);
                    lambda = distribParams(1);
                    if lambda ~= 0
                         u = rand( sampleSize );
                         out = (u.^lambda - (1-u).^lambda) / lambda;
                    else
                         out = feval(funcName,'logistic', [0 1], sampleSize);
                    end
                    
               case {'u', 'ushape'}
                    % START u HELP  START ushape HELP
                    % THE U DISTRIBUTION
                    %   ( U-shape distribution )
                    %
                    % Standard form of the U distribution:
                    %
                    %   pdf(y) = 1./(pi*sqrt(1-y.^2)); -1<=y<=1;
                    %   cdf(y) = 1/2 + 1/pi*asin(y); -1<=y<=1;
                    %
                    %  Mean = 0;
                    %  Variance = 1/2;
                    %
                    % General form of the U distribution:
                    %
                    %   pdf(y) = 1./(pi*sqrt(s^2-(y-t).^2));  t-s<=y<=t+s; s>0
                    %   cdf(y) = 1/2 + 1/pi*asin((y-t)/a); -1<=y<=1;
                    %
                    %  Mean = t;
                    %  Variance = s^2/2;
                    %
                    % PARAMETERS:  
                    %   t - location
                    %   s -scale; s>0
                    %
                    % SUPPORT:      
                    %   y,   -1 <= y <= 1   - standard U distribution
                    %    or
                    %   y,   t-s <= y <= t+s  - generalized U distribution
                    %
                    % CLASS:
                    %   Continuous symmetric distributions
                    %
                    % USAGE:
                    %   randraw('u', [], sampleSize) - generate sampleSize number
                    %         of variates from standard U distribution;
                    %   randraw('u', [t, s], sampleSize) - generate sampleSize number
                    %         of variates from generalized U distribution
                    %         with location parameter 't' and scale parameter 's';
                    %   randraw('u') - help for U distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('u', [], [1 1e5]);
                    %  2.   y = randraw('u', [], 1, 1e5);
                    %  3.   y = randraw('u', [], 1e5 );
                    %  4.   y = randraw('u', [10 3], [1e5 1] );
                    %  5.   randraw('u');
                    %
                    % SEE ALSO:
                    %    ARCSIN distribution                    
                    % END u HELP END ushape HELP
                    
                    checkParamsNum(funcName, 'U', 'u', distribParams, [0, 2]);  
                    if numel(distribParams)==2
                         t  = distribParams(1);
                         s  = distribParams(2);  
                         validateParam(funcName, 'U', 'u', '[t, s]', 's', s, {'> 0'});
                    else
                         t = 0;
                         s = 1;                        
                    end   
                    
                    out = t + s * sin(pi*(rand(sampleSize)-0.5));
                    
               case {'uniform', 'unif'}
                    % START uniform HELP START unif HELP
                    % THE UNIFORM DISTRIBUTION
                    % 
                    % pdf = 1/(b-a);
                    % cdf = (y-a)/(b-a);
                    % 
                    %  Mean = (a+b)/2;
                    %  Variance = (b-a)^2/12;
                    %
                    % PARAMETERS:
                    %   a is location of y (lower bound);
                    %   b is scale of y (upper bound)  (b > a);
                    %
                    % SUPPORT:
                    %   y,  a < y < b
                    %
                    % CLASS:
                    %  Continuous symmetric distributions
                    %
                    % USAGE:
                    %   randraw('uniform', [], sampleSize) - generate sampleSize number
                    %         of variates from standard Uniform distribution (a=0, b=1);
                    %   randraw('uniform', [a, b], sampleSize) - generate sampleSize number
                    %         of variates from the Uniform distribution
                    %         with parameters 'a' and 'b';
                    %   randraw('uniform') - help for the Uniform distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('uniform', [], [1 1e5]);
                    %  2.   y = randraw('uniform', [2, 3], 1, 1e5);
                    %  3.   y = randraw('uniform', [5, 6], 1e5 );
                    %  4.   y = randraw('uniform', [10.5, 11.5], [1e5 1] );
                    %  5.   randraw('uniform');                    
                    % END uniform HELP END unif HELP
                    
                    checkParamsNum(funcName, 'Uniform', 'uniform', distribParams, [0, 2]);  
                    if numel(distribParams)==2
                         a  = distribParams(1);
                         b  = distribParams(2);  
                         validateParam(funcName, 'Uniform', 'uniform', '[a, b]', 'b-a', b-a, {'> 0'});
                    else
                         a = 0;
                         b = 1;                        
                    end   
                    
                    out = a + (b-a)*rand( sampleSize );

               case {'vonmises'}
                    % START vonmises HELP
                    % THE VON MISES DISTRIBUTION
                    % A continuous distribution defined on the range [0, 2*pi)
                    % with probability density function:
                    %
                    %  pdf(y) = exp(k*cos(y-a)) ./ (2*pi*besseli(0,k));
                    %
                    %  where besseli(0,x) is a modified Bessel function of the
                    %  first kind of order 0.
                    %  Here,  'a' (a>=0 and a<2*pi) is the mean direction and k > 0 is a
                    %  concentration parameter
                    %  The von Mises distribution is the circular analog of the normal
                    %  distribution on a line.
                    %
                    %  Mean = a;
                    %
                    %  PARAMETERS:
                    %    a - location parameter, (a>=0 and a<2*pi)
                    %    k - shape parameter,  (k>0)
                    %
                    %  SUPPORT:
                    %    y,  -pi < y < pi
                    %
                    %  CLASS:
                    %     Continuous distribution
                    %
                    % USAGE:
                    %   randraw('vonmises', [a, k], sampleSize) - generate sampleSize number
                    %         of variates from the von Mises distribution with parameters 'a' and 'k';
                    %   randraw('vonmises') - help for the von Mises distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('vonmises', [pi/2, 3], [1 1e5]);
                    %  2.   y = randraw('vonmises', [2*pi/3, 2], 1, 1e5);
                    %  3.   y = randraw('vonmises', [pi/4, 10], 1e5 );
                    %  4.   y = randraw('vonmises', [pi, 2.2], [1e5 1] );
                    %  5.   randraw('vonmises');                       
                    % END vonmises HELP
                    
                    %  Method:
                    %   1) For large k (say, k>700) von Mises distribution tends
                    %      to a Normal Distribution with variance 1/?
                    %   2) For a small k we implement method suggested in:
                    %      L. Yuan and J.D. Kalbleisch, "On the Bessel distribution and
                    %      related problems," Annals of the Institute of Statistical
                    %      Mathematics, vol. 52, pp. 438-447, 2000
                    %      and described in:
                    %      Luc Devroye, "Simulating Bessel Random Variables,"
                    %      Statistics and Probability Letters, vol. 57, pp. 249-257, 2002.
                    %


                    a = distribParams(1);
                    k = distribParams(2);

                    if k > 700
                         % for large k it tends to a Normal Distribution with variance 1/k
                         out = a + sqrt(1/k)*randn( sampleSize );
                    else
                         % Generate X <- Bessel(0,k)
                         x = feval(funcName,'bessel', [0 k], sampleSize);

                         % Generate B <- beta(X+1/2, 1/2);
                         u2 = rand( sampleSize );
                         l = (x>0);
                         d1 = (cos(2*pi*u2(l))).^2;
                         d2 = (cos(pi*u2(~l))).^2;
                         clear('u2');
                         t = 2./(2*(x(l)+0.5)-1);
                         clear('x');
                         b = zeros( sampleSize );
                         u1 = rand(sum(l(:)),1);
                         b(l) = 1 - (1-u1.^t(:)) .* d1(:);
                         clear('t');
                         b(~l) = d2;
                         clear('d1');
                         clear('d2');

                         % if U < 1/(1+exp(-2*k*sqrt(B))),
                         %       then return S*acos(sqrt(B))
                         %       else return S*acos(-sqrt(B))
                         %     where S is a random sign
                         l = rand(sampleSize) < 1./(1+exp(-2*k*sqrt(b)));
                         out = zeros( sampleSize );
                         out(l) = acos(sqrt(b(l)));
                         out(~l) = acos(-sqrt(b(~l)));
                         clear('b');
                         clear('l');

                         out = a + (2*round(rand(sampleSize))-1) .* out;
                    end

               case {'wald'}
                    % START wald HELP
                    % THE WALD DISTRIBUTION
                    %
                    % The Wald distribution is as special case of the Inverse Gaussian Distribution
                    % where the mean is a constant with the value one.
                    %
                    % pdf = sqrt(chi/(2*pi*y^3)) * exp(-chi./(2*y).*(y-1).^2);
                    %
                    % Mean     = 1;
                    % Variance = 1/chi;
                    % Skewness = sqrt(9/chi);
                    % Kurtosis = 3+ 15/scale;
                    %
                    % PARAMETERS:
                    %  chi - scale parameter; (chi>0)
                    %
                    % SUPPORT:
                    %  y,  y>0
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % USAGE:
                    %   randraw('wald', chi, sampleSize) - generate sampleSize number
                    %         of variates from the Wald distribution with scale parameter 'chi';
                    %   randraw('wald') - help for the Wald distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('wald', 0.5, [1 1e5]);
                    %  2.   y = randraw('wald', 1, 1, 1e5);
                    %  3.   y = randraw('wald', 1.5, 1e5 );
                    %  4.   y = randraw('wald', 2, [1e5 1] );
                    %  5.   randraw('wald');                       
                    % END wald HELP
                                        
                    checkParamsNum(funcName, 'Wald', 'wald', distribParams, [1]);
                    chi = distribParams(1);
                    validateParam(funcName, 'Wald', 'wald', 'chi', 'chi', chi, {'> 0'});
                    
                    out = feval(funcName, 'ig', [1 chi], sampleSize);

               case {'weibull', 'frechet', 'wbl'} 
                    % START weibull HELP START frechet HELP START wbl HELP
                    %  THE WEIBULL DISTRIBUTION
                    %  ( sometimes: Frechet distribution )
                    % 
                    %  cdf = 1 - exp(-((y-theta)/beta).^alpha)
                    %  pdf = alpha / beta * ((y-theta)/beta).^(alpha-1) .* exp(-((y-theta)/beta).^alpha);
                    %
                    %  Mean = theta + beta*gamma((alpha+1)/alpha);  
                    %  Variance = beta^2 * ( gamma((alpha+2)/alpha) - gamma((alpha+1)/alpha)^2 );
                    %       where gamma is the gamma function
                    %
                    % PARAMETERS:
                    %   theta - location parameter;
                    %   alpha - shape parameter ( alpha>0 );
                    %   beta  - scale parameter ( beta>0 );
                    %
                    % SUPPORT:
                    %   y,  y > theta
                    %
                    % CLASS:
                    %   Continuous skewed distributions
                    %
                    % NOTES:
                    %   If alpha=1 , it is the exponential distribution
                    %   If beta=1; alpha=2, theta=0; it is the standard Rayleigh distribution (sigma=1)
                    %
                    % USAGE:
                    %   randraw('weibull', [theta, alpha, beta], sampleSize) - generate sampleSize number
                    %         of variates from the Weibull distribution with location parameter 'theta',
                    %         shape parameter 'alpha' and scale parameter 'beta';
                    %   randraw('weibull') - help for the Weibull distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('weibull', [-10, 2, 3], [1 1e5]);
                    %  2.   y = randraw('weibull', [0, 2, 1], 1, 1e5);
                    %  3.   y = randraw('weibull', [0, 1, 2], 1e5 );
                    %  4.   y = randraw('weibull', [2.1, 5.4, 10.2], [1e5 1] );
                    %  5.   randraw('weibull');                        
                    % END weibull HELP END frechet HELP END wbl HELP

                    checkParamsNum(funcName, 'Weibull', 'weibull', distribParams, [3]);
                    theta = distribParams(1);
                    alpha = distribParams(2);
                    beta  = distribParams(3);
                    validateParam(funcName, 'Weibull', 'weibull', '[theta, alpha, beta]', 'alpha', alpha, {'> 0'});
                    validateParam(funcName, 'Weibull', 'weibull', '[theta, alpha, beta]', 'beta', beta, {'> 0'});                    
                    
                    out = theta + beta * (-log(rand( sampleSize ))).^(1/alpha);

               case {'yule', 'yulesimon'}
                    % START yule HELP START yulesimon HELP
                    % THE YULE-SIMON DISTRIBUTION 
                    %
                    %  pmf(y) = (p-1)*beta(y, p); p>1; y = 1, 2, 3, 4, ...
                    %  cdf(y) = 1-(y+1).*beta(y+1,p);
                    %
                    %  Mean = (p-1)/(p-2); for p>2;
                    %  Variance = (p-1)^2/((p-2)^2*(p-3)); for p>3;
                    %
                    %  PARAMETERS:
                    %    p,  p>1
                    %
                    %  SUPPORT:
                    %    y,  y = 1, 2, 3, 4, ...
                    %
                    %  CLASS:
                    %    Discrete distributions
                    %
                    %  NOTES:
                    %    1. It is named after George Udny Yule and Herbert Simon. 
                    %       Simon originally called it the Yule distribution.
                    %    2. The probability mass function pmf(y) has the property that 
                    %       for sufficiently large y we have
                    %        pmf(y) = (p-1)*gamma(p)./y.^p;
                    %       This means that the tail of the Yule-Simon distribution is a 
                    %       realization of Zipf's law: pmf(y) can be used to model, 
                    %       for example, the relative frequency of the y'th most frequent 
                    %       word in a large collection of text, which according to Zipf's law
                    %       is inversely proportional to a (typically small) power of y.
                    %  
                    % USAGE:
                    %   randraw('yule', p, sampleSize) - generate sampleSize number
                    %         of variates from the Yule-Simon distribution with parameter 'p';
                    %   randraw('yule') - help for the Yule-Simon distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('yule', 2, [1 1e5]);
                    %  2.   y = randraw('yule', 3.2, 1, 1e5);
                    %  3.   y = randraw('yule', 100.5, 1e5 );
                    %  4.   y = randraw('yule', 33, [1e5 1] );
                    %  5.   randraw('yule');                                        
                    % END yule HELP END yulesimon HELP
                    
                    % Rference:
                    %    Luc Devroye,
                    %    "Non-Uniform Random Variate Generation,"
                    %    Springer Verlag, 1986, pages 550-551.
                    
                    checkParamsNum(funcName, 'Yule-Simon', 'yule', distribParams, [1]);
                    p = distribParams(1);
                    validateParam(funcName, 'Yule-Simon', 'yule', 'p', 'p', p, {'> 1'});
                                        
                    out = ceil( log(rand(sampleSize)) ./ log(1-exp(log(rand(sampleSize))/(p-1))) ); 
                    
               case {'zeta', 'zipf'}
                    % START zeta HELP  START zipf HELP
                    % ZETA DISTRIBUTION
                    %   (sometimes: Zipf distribution)
                    %
                    %  pmf(n) = 1. / (n^a * zeta(a)),
                    %    where zeta(s) is a Riemann Zeta function:
                    %         sum from i=1 to Inf of 1/i^a
                    %    a>1
                    %        
                    %  Mean = zeta(a-1)/zeta(a), for a>2
                    %  Variance = zeta(a-2)/zeta(a) - (zeta(a-1)/zeta(a))^2;
                    %
                    % PARAMETERS:  
                    %   a > 1
                    %
                    % SUPPORT:      
                    %   n = 1, 2, 3, ... (positive integers)
                    %
                    % CLASS:
                    %   Discrete distributions
                    %
                    % NOTES:
                    % The zeta distribution is a long-tailed distribution that is useful for 
                    % size-frequency data. It is sometimes used in insurance as a model for
                    % the number of policies held by a single person in an insurance portfolio. 
                    % It is also used for the analysis of the frequency of words in long 
                    % sequences of text. When used in linguistics the zeta distribution is 
                    % known as the Zipf distribution.
                    %
                    % USAGE:
                    %   randraw('zeta', a, sampleSize) - generate sampleSize number
                    %         of variates from standard Zeta distribution with parameter a;
                    %   randraw('zeta') - help for Zeta distribution;
                    %
                    % EXAMPLES:
                    %  1.   y = randraw('zeta', 2, [1 1e5]);
                    %  2.   y = randraw('zeta', 3.5, 1, 1e5);
                    %  3.   y = randraw('zeta', 10, 1e5 );
                    %  4.   y = randraw('zeta', 100, [1e5 1] );
                    %  5.   randraw('zeta');
                    % END zeta HELP  END zipf HELP                    
                    
                    %  Reference:
                    %    Luc Devroye,
                    %    "Non-Uniform Random Variate Generation,"
                    %    Springer Verlag, 1986, pages 550-551.

                    a = distribParams(1);

                    b = 2^(a-1);
                    am1 = a - 1;
                    bm1 = b - 1;

                    u1 = rand( sampleSize );
                    out = floor( u1.^(-1/am1) );
                    clear('u1');
                    u2 = rand( sampleSize );
                    t = ( 1 + 1./out ).^(a-1);

                    indxs = find( u2.*out.*(t-1)/bm1 > t/b );

                    while ~isempty(indxs)
                         indxsSize = size( indxs );
                         u1 = rand( indxsSize );
                         outNew = floor( u1.^(-1/am1) );
                         clear('u1');
                         u2 = rand( indxsSize );
                         t = ( 1 + 1./outNew ).^(a-1);

                         l = u2.*outNew.*(t-1)/bm1 <= t/b;

                         out( indxs(l) ) = outNew(l);
                         indxs = indxs(~l);
                    end

               otherwise
                    fprintf('\n RANDRAW: Unknown distribution name: %s \n', distribName);
                    
          end % switch lower( distribNameInner )
          
     end % if prod(sampleSize)>0

     varargout{1} = out;

     return;

end % if strcmp(runMode, 'genRun')

return;
end

function checkParamsNum(funcName, distribName, runDistribName, distribParams, correctNum)
if ~any( numel(distribParams) == correctNum )
     error('%s Variates Generation:\n %s%s%s%s%s', ...
          distribName, ...
          'Wrong numebr of parameters (run ',...
          funcName, ...
          '(''', ...
          runDistribName, ...
          ''') for help) ');
end
return;
end

function validateParam(funcName, distribName, runDistribName, distribParamsName, paramName, param, conditionStr)
condLogical = 1;
eqCondStr = [];
for nn = 1:length(conditionStr)
     if nn==1
          eqCondStr = [eqCondStr conditionStr{nn}];
     else
          eqCondStr = [eqCondStr ' and ' conditionStr{nn}];          
     end
     eqCond = conditionStr{nn}(1:2);
     eqCond = eqCond(~isspace(eqCond));
     switch eqCond
          case{'<'}
               condLogical = condLogical & (param<str2num(conditionStr{nn}(3:end)));
          case{'<='}
               condLogical = condLogical & (param<=str2num(conditionStr{nn}(3:end)));               
          case{'>'}
               condLogical = condLogical & (param>str2num(conditionStr{nn}(3:end))); 
          case{'>='}
               condLogical = condLogical & (param>=str2num(conditionStr{nn}(3:end)));
          case{'~='}
               condLogical = condLogical & (param~=str2num(conditionStr{nn}(3:end)));
          case{'=='}
               if strcmp(conditionStr{nn}(3:end),'integer')
                    condLogical = condLogical & (param==floor(param));                    
               else
                    condLogical = condLogical & (param==str2num(conditionStr{nn}(3:end)));
               end
     end
end

if ~condLogical
     error('%s Variates Generation: %s(''%s'',%s, SampleSize);\n Parameter %s should be %s\n (run %s(''%s'') for help)', ...
          distribName, ...
          funcName, ...
          runDistribName, ...
          distribParamsName, ...
          paramName, ...
          eqCondStr, ...
          funcName, ...
          runDistribName);
end
return;
end

function cdf = normcdf(y)
cdf = 0.5*(1+erf(y/sqrt(2)));
return;
end

function pdf = normpdf(y)
pdf = 1/sqrt(2*pi) * exp(-1/2*y.^2);
return;
end

function cdfinv = norminv(y)
cdfinv = sqrt(2) * erfinv(2*y - 1);
return;
end

function out = randFrom5Tbls( P, offset, sampleSize)
sizeP = length(P);
if sizeP == 0
     out = [];
     return;
end
a = mod(floor([0 P]/16777216), 64);
na = cumsum( a );
b = mod(floor([0 P]/262144), 64);
nb = cumsum( b );
c = mod(floor([0 P]/4096), 64);
nc = cumsum( c );
d = mod(floor([0 P]/64), 64);
nd = cumsum( d );
e =  mod([0 P], 64);
ne = cumsum( e );

AA = zeros(1, na(end));
BB = zeros(1, nb(end));
CC = zeros(1, nc(end));
DD = zeros(1, nd(end));
EE = zeros(1, ne(end));

t1 = na(end)*16777216;
t2 = t1 + nb(end)*262144;
t3 = t2 + nc(end)*4096;
t4 = t3 + nd(end)*64;

k = (1:sizeP)+offset-1;
for ii = 1:sizeP
     AA(na(ii)+(0:a(ii+1))+1) = k(ii);
     BB(nb(ii)+(0:b(ii+1))+1) = k(ii);
     CC(nc(ii)+(0:c(ii+1))+1) = k(ii);
     DD(nd(ii)+(0:d(ii+1))+1) = k(ii);
     EE(ne(ii)+(0:e(ii+1))+1) = k(ii);
end

%jj = round(1073741823*rand(sampleSize));
jj = round(min(sum(P),1073741823) *rand(sampleSize));
out = zeros(sampleSize);
N = prod(sampleSize);
for ii = 1:N
     if jj(ii) < t1
          out(ii) = AA( floor(jj(ii)/16777216)+1 );
     elseif jj(ii) < t2
          out(ii) = BB(floor((jj(ii)-t1)/262144)+1);
     elseif jj(ii) < t3
          out(ii) = CC(floor((jj(ii)-t2)/4096)+1);
     elseif jj(ii) < t4
          out(ii) = DD(floor((jj(ii)-t3)/64)+1);
     else
          out(ii) = EE(floor(jj(ii)-t4) + 1);
     end
end

return;

end