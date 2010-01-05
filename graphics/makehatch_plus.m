function A = makehatch_plus(hatch,n,m)
%MAKEHATCH_PLUS Predefined hatch patterns
%
% Modification of MAKEHATCH to allow for selection of matrix size. Useful whe using 
%   APPLYHATCH_PLUS with higher resolution output.
%
% input (optional) N    size of hatch matrix (default = 6)
% input (optional) M    width of lines and dots in hatching (default = 1)
%
%  MAKEHATCH_PLUS(HATCH,N,M) returns a matrix with the hatch pattern for HATCH
%   according to the following table:
%      HATCH        pattern
%     -------      ---------
%        /          right-slanted lines
%        \          left-slanted lines
%        |          vertical lines
%        -          horizontal lines
%        +          crossing vertical and horizontal lines
%        x          criss-crossing lines
%        .          square dots
%        c          circular dots
%        w          Just a blank white pattern
%        k          Just a totally black pattern
%
%  See also: APPLYHATCH, APPLYHATCH_PLUS, APPLYHATCH_PLUSCOLOR, MAKEHATCH

%  By Ben Hinkle, bhinkle@mathworks.com
%  This code is in the public domain. 

% Modified Brian FG Katz    8-aout-03
% Modified David M Kaplan    19-fevrier-08

if ~exist('n','var'), n = 6; end
if ~exist('m','var'), m = 1; end
n=round(n);

switch (hatch)
  case '\'
    [B,C] = meshgrid( 0:n-1 );
    B = B-C; 
    clear C
    A = abs(B) <= m/2;
    A = A | abs(B-n) <= m/2;
    A = A | abs(B+n) <= m/2;
  case '/'
    A = fliplr(makehatch_plus('\',n,m));
  case '|'
    A=zeros(n);
    A(:,1:m) = 1;
  case '-'
    A = makehatch_plus('|',n,m);
    A = A';
  case '+'
    A = makehatch_plus('|',n,m);
    A = A | A';
  case 'x'
    A = makehatch_plus('\',n,m);
    A = A | fliplr(A);
  case '.'
    A=zeros(n);
    A(1:2*m,1:2*m)=1;
  case 'c'
    [B,C] = meshgrid( 0:n-1 );
    A = sqrt(B.^2+C.^2) <= m;
    A = A | fliplr(A) | flipud(A) | flipud(fliplr(A));
  case 'w'
    A = zeros(n);
  case 'k'
    A = ones(n);
  otherwise
    error(['Undefined hatch pattern "' hatch '".']);
end