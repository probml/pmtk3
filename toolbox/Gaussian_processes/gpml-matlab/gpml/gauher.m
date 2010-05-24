% compute abscissas and weight factors for Gaussian-Hermite quadrature
%
% CALL:  [x,w]=gauher(N)
%  
%  x = base points (abscissas)
%  w = weight factors
%  N = number of base points (abscissas) (integrates a (2N-1)th order
%      polynomial exactly)
%
%  p(x)=exp(-x^2/2)/sqrt(2*pi), a =-Inf, b = Inf 
%
%  The Gaussian Quadrature integrates a (2n-1)th order
%  polynomial exactly and the integral is of the form
%           b                         N
%          Int ( p(x)* F(x) ) dx  =  Sum ( w_j* F( x_j ) )
%           a                        j=1		          
%
%      this procedure uses the coefficients a(j), b(j) of the
%      recurrence relation
%
%           b p (x) = (x - a ) p   (x) - b   p   (x)
%            j j            j   j-1       j-1 j-2
%
%      for the various classical (normalized) orthogonal polynomials,
%      and the zero-th moment
%
%           1 = integral w(x) dx
%
%      of the given polynomial's weight function w(x).  Since the
%      polynomials are orthonormalized, the tridiagonal matrix is
%      guaranteed to be symmetric.

function [x,w]=gauher(N)
    if N==20 % return precalculated values
        x=[ -7.619048541679757;-6.510590157013656;-5.578738805893203;
            -4.734581334046057;-3.943967350657318;-3.18901481655339 ;
            -2.458663611172367;-1.745247320814127;-1.042945348802751;
            -0.346964157081356; 0.346964157081356; 1.042945348802751;
             1.745247320814127; 2.458663611172367; 3.18901481655339 ;
             3.943967350657316; 4.734581334046057; 5.578738805893202;
             6.510590157013653; 7.619048541679757];
        w=[  0.000000000000126; 0.000000000248206; 0.000000061274903;
             0.00000440212109 ; 0.000128826279962; 0.00183010313108 ;
             0.013997837447101; 0.061506372063977; 0.161739333984   ;
             0.260793063449555; 0.260793063449555; 0.161739333984   ;
             0.061506372063977; 0.013997837447101; 0.00183010313108 ;
             0.000128826279962; 0.00000440212109 ; 0.000000061274903;
             0.000000000248206; 0.000000000000126 ];
    else
        b = sqrt( (1:N-1)/2 )';    
        [V,D] = eig( diag(b,1) + diag(b,-1) );
        w = V(1,:)'.^2;
        x = sqrt(2)*diag(D);
    end