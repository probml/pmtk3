%% This function returns the numerical derivative of an analytic function.
% Of special note, is the incorporation of the "complex step-derivative"
% approach which offers greatly improved derivative accuracy compared to 
% forward and central difference approximations.  This is especially germain 
% when accuracy at the level of machine precision is a concern.
%
% This function was motivated by: <a href="matlab:web('http://www.biomedicalcomputationreview.org/2/3/8.pdf','-browser')">Complex Step Derivatives</a> authored by Michael Sherman
%   -The function with no inputs generates the example used in the above link.
%   -For more information see the following citation which is also found in the above link:
%      --Martins JR, Sturdza P, and Alonso JJ
%        <a href="matlab:web('http://portal.acm.org/citation.cfm?id=838250.838251','-browser')">The complex-step derivative approximation</a>
%        ACM Trans. Math. Softw. 29(3) (2003)
%
% SYNTAX:   dfdx=deriv(f,x,h,method)
%
% INPUTS:   f      - A function a handle (eg f=@(x) sin(x))
%           x      - Interval over which f(x) is defined
%           h      - Derivative step-size
%           method - Numerical methods used to compute derivative
%                    'forward2' - Two point forward difference
%                    'forward3' - Three point forward difference
%                    'central2' - Two point central difference
%                    'central4' - Four point central difference
%                    'complex'  - Complex step-derivative approximation
%
% OUTPUTS:  dfdx   - Numerical estimate of the derivative of f(x)
%
% Example:  These simple examples produce results in the stack if the "links" are clicked.
%           Compare the accuracy of different methods:
%             <a href="matlab:eval('deriv;')">>> deriv</a>
%
%           Example of how to use the function:
%             <a href="matlab:eval('x=linspace(0,2*pi,1e3);')">>>x=linspace(0,2*pi,1e3);</a>
%             <a href="matlab:eval('f=@(x) sin(x);')">>>f=@(x) sin(x);</a>
%             <a href="matlab:eval('dfdx=deriv(f,x,1e-3,''forward2''); fprintf(''The results are in the STACK.\n'')')">>>dfdx=deriv(f,x,1e-3,'forward2');</a>
%
% DBE 2006.07.31
%PMTKurl http://www.mathworks.com/matlabcentral/files/11870/deriv.m
%PMTKauthor Daniel Ellis 
%%

% This file is from pmtk3.googlecode.com

function dfdx=derivComplexTrick(f,x,h,method)

DISP=0;  % Flag to turn on/off a plot of the result...this is of marginal utility, therefore the default is ZERO

if nargin==0 % Generate an example of different derivatives and their precision.

  DISP=0;

  f=@(x) sin(3*x).*log(x);

  h2=1e-7;
  h3=1e-5;
  hc=1e-20;
  x=[0.7];

  format long
  dfdxForward2 =(f(x+h2)-f(x))   /   h2 ;                           % Two Point Forward Difference
  dfdxCentral2 =(f(x+h3)-f(x-h3))/(2*h3);                           % Two Point Central Difference

  dfdxForward3 =(-f(x+2*h2)+4*f(x+h2)-3*f(x))/(2*h2);               % Three Point Forward Difference
  dfdxCentral4 =(-f(x+2*h3)+8*f(x+h3)-8*f(x-h3)+f(x-2*h3))/(12*h3); % Four Point Central Difference

  dfdxComplex =imag(f(x+hc*i)   /   hc);                            % Complex difference
  dfdxAnalytic=sin(3*x)./x+3*cos(3*x).*log(x);                      % Analytic result
  
  fprintf('Evaluating the numerical derivative of the analytic function, f(x)=sin(3x).*log(x) @ x=0.7.\n');
  fprintf('Comparison of precision of each numerical method to the analytic result:\n');
  fprintf(' Note the differences in step size.\n');
  fprintf(['  df/dx Forward_2 = ',num2str(dfdxForward2 ,'%.16f'),', Stepsize=',num2str(h2,'%3.1e'),'\n']);
  fprintf(['  df/dx Centra1_2 = ',num2str(dfdxCentral2 ,'%.16f'),', Stepsize=',num2str(h3,'%3.1e'),'\n']);
  fprintf(['  df/dx Forward_3 = ',num2str(dfdxForward3 ,'%.16f'),', Stepsize=',num2str(h2,'%3.1e'),'\n']);
  fprintf(['  df/dx Central_4 = ',num2str(dfdxCentral4 ,'%.16f'),', Stepsize=',num2str(h3,'%3.1e'),'\n']);
  fprintf(['  df/dx Complex   = ',num2str(dfdxComplex  ,'%.16f'),', Stepsize=',num2str(hc,'%3.1e'),'\n']);
  fprintf(['  df/dx Analytic  = ',num2str(dfdxAnalytic ,'%.16f'),'\n']);

  if DISP  % This is *marginally* useful...
    warning('It is VERY hard to see the results visually due to the level of precision involved...');
    figure; hold on;
    xx=linspace(1e-6,1.4,1e3);
    plot(xx,f(xx),'k');

    xx_max=0;
    xx_min=1.4;
    plot([xx_min xx_max],[f(x)+dfdxForward2*(xx_min-x) f(x)+dfdxForward2*(xx_max-x)],'r');
    plot([xx_min xx_max],[f(x)+dfdxCentral2*(xx_min-x) f(x)+dfdxCentral2*(xx_max-x)],'g');
    plot([xx_min xx_max],[f(x)+dfdxAnalytic*(xx_min-x) f(x)+dfdxAnalytic*(xx_max-x)],'b');
  end
elseif nargin==4
  DISP=0;

  switch lower(method)
    case 'forward2'                                           % Two point forward difference
      dfdx=(f(x+h)-f(x))/h;
    case 'central2'                                           % Two point central difference
      dfdx=(f(x+h)-f(x-h))/(2*h);
    case 'forward3'                                           % Three point forward difference
      dfdx=(-f(x+2*h)+4*f(x+h)-3*f(x))/(2*h);
    case 'central4'                                           % Four point central difference
      dfdx =(-f(x+2*h)+8*f(x+h)-8*f(x-h)+f(x-2*h))/(12*h);
    case 'complex'                                            % Complex difference
      dfdx=imag(f(x+h*i)/h);                                  % This is the *magic*
    otherwise
      error('Derivative METHOD not known.');
  end
  
  if DISP  % This is *marginally* useful...
    figure; hold on;
      plot(x,f(x),'r');
      plot(x,dfdx,'b');
      legend('f(x)','df(x)/dx');
  end
else
  error('FOUR input arguments are REQUIRED.');
end

return
end
