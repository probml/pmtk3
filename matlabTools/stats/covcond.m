function [Sig,Lam] = covcond(c,a)
% Generate a covariance matrix and its inverse with a given cond number
% C and first direction A.
%COVCOND covariance matrix with given condition number
% [Sig,Lam] = covcond(C,A) generates covariance matrix and its
% inverse with given cond number C and first direction A.

% This file is from pmtk3.googlecode.com


%PMTKauthor Marko Laine
%PMTKurl http://www.helsinki.fi/~mjlaine/mcmc/

% $Revision: 1.2 $  $Date: 2007/08/10 10:49:52 $

% create orthogonal basis z, with 1 direction given by 'a'
a     = a(:);
e     = sort(1./linspace(c,1,length(a)));
a(1)  = a(1) + sign(a(1)) * norm(a);  %the Householder trick 
z     = eye(length(a)) - 2.0/norm(a)^2*a*a'; 
Sig   = z * diag(e) * z' ;              % target covariance
Lam   = z * inv(diag(e)) * z';          % and its inverse

end
