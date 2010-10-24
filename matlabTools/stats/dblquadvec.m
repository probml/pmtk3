function q = dblquadvec(f, varargin)
% Calls dblquadvec but assumes you can't vectorize your input function
%   DBLQUADVEC has the same calling syntax as DBLQUAD but doesn't require that
%   the integrand be vectorized.
%
%   Q = DBLQUADVEC(FUN,A,B) tries to approximate the integral of scalar-valued
%   function FUN from A to B to within an error of 1.e-6 using recursive
%   adaptive Simpson quadrature. FUN is a function handle.
%
%   See also
%     DBLQUAD
%
%PMTKauthor Aki Vehtari
%PMTKurl http://www.lce.hut.fi/teaching/S-114.2601/ex/dblquadvec.m

% This file is from pmtk3.googlecode.com


% Based on quadvec by Loren Shure
% http://www.mathworks.com/matlabcentral/fileexchange/loadFile.do?objectId=10667&objectType=file

q = dblquad(@g, varargin{:}); % like quadl, but supplies g as the argument
    function y = g(A,B,varargin) % make f into a "vectorized" function
        y = zeros(size(A));
        for i = 1:numel(A)
            y(i) = f(A(i),B,varargin{:}); % this f refers to the argument of quadvec
        end
    end
end
