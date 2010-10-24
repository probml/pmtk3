function [pdf,pdd] = mpbdv(v,x)
%% Parabolic cylinder function
%       =========================================================
%       Purpose: This program computes the parabolic cylinder
%                functions Dv(x) and their derivatives using
%                subroutine PBDV
%       Input:   x --- Argument of Dv(x)
%                v --- Order of Dv(x)
%
%                PDF --- Dv(x)
%                PDD --- Dv'(x)
%
% This program is a direct conversion of the corresponding Fortran program in
% S. Zhang & J. Jin "Computation of Special Functions" (Wiley, 1996).
% online: http://iris-lee3.ece.uiuc.edu/~jjin/routines/routines.html
%
% Converted by f2matlab open source project:
% online: https://sourceforge.net/projects/f2matlab/
% written by Ben Barrowes (barrowes@alum.mit.edu)
%
% Slightly modified by Mahieddine. M. ICHIR
%
%PMTKauthor Ben Barrowes, M. Mahieddine
%PMTKurl https://sourceforge.net/projects/f2matlab/

% This file is from pmtk3.googlecode.com


dv  = [];
dp  = [];
pdf = [];
pdd = [];
dv = zeros(100+1,1);
dp = zeros(100+1,1);

nv = fix(v);
v0 = v-nv;
na = abs(nv);

[v,x,dv,dp,pdf,pdd] = pbdv(v,x,dv,dp,pdf,pdd);

for  k = 0:na;
  vk = k.*(abs(1).*sign(nv))+v0;
end
end

%%%%%%%%%%%%%%%% SUBROUTINES
function [v,x,dv,dp,pdf,pdd] = pbdv(v,x,dv,dp,pdf,pdd);
%                and their derivatives
%       Input:   x --- Argument of Dv(x)
%                v --- Order of Dv(x)
%       Output:  DV(na) --- Dn+v0(x)
%                DP(na) --- Dn+v0'(x)
%                ( na = |n|, v0 = v-n, |v0| < 1,
%                  n = 0,ס1,ס2,תתת )
%                PDF --- Dv(x)
%                PDD --- Dv'(x)
%       Routines called:
%             (1) DVSA for computing Dv(x) for small |x|
%             (2) DVLA for computing Dv(x) for large |x|
%       ====================================================
%


v1  = [];
pd1 = [];
v0  = [];
pd0 = [];
v2  = [];
f1  = [];
f0  = [];
xa  = abs(x);
vh  = v;
v   = v+(abs(1.0d0).*sign(v));
nv  = fix(v);
v0  = v-nv;
na  = abs(nv);
ep  = exp(-.25d0.*x.*x);
if (na >= 1) ja=1; end;
if (v >= 0.0) ;
  if (v0 == 0.0) ;
    pd0 = ep;
    pd1 = x.*ep;
  else;
    for l = 0:ja;
      v1 = v0+l;
      if (xa <= 5.8) [v1,x,pd1] = dvsa(v1,x,pd1); end;
      if (xa > 5.8) [v1,x,pd1]  = dvla(v1,x,pd1); end;
      if (l == 0) pd0 = pd1; end;
    end;
  end;
  dv(0+1) = pd0;
  dv(1+1) = pd1;
  for  k = 2:na;
    pdf = x.*pd1-(k+v0-1.0d0).*pd0;
    dv(k+1) = pdf;
    pd0 = pd1;
    pd1 = pdf;
  end;
else;
  if (x <= 0.0) ;
    if (xa <= 5.8d0)  ;
      [v0,x,pd0] = dvsa(v0,x,pd0);
      v1 = v0-1.0d0;
      [v1,x,pd1] = dvsa(v1,x,pd1);
    else;
      [v0,x,pd0] = dvla(v0,x,pd0);
      v1 = v0-1.0d0;
      [v1,x,pd1] = dvla(v1,x,pd1);
    end;
    dv(0+1) = pd0;
    dv(1+1) = pd1;
    for  k = 2:na;
      pd = (-x.*pd1+pd0)./(k-1.0d0-v0);
      dv(k+1) = pd;
      pd0 = pd1;
      pd1 = pd;
    end;
  elseif (x <= 2.0);
    v2 = nv+v0;
    if (nv == 0) v2 = v2-1.0d0; end;
    nk = fix(-v2);
    [v2,x,f1] = dvsa(v2,x,f1);
    v1 = v2+1.0d0;
    [v1,x,f0] = dvsa(v1,x,f0);
    dv(nk+1) = f1;
    dv(nk-1+1) = f0;
    for  k = nk-2:-1:0;
      f = x.*f0+(k-v0+1.0d0).*f1;
      dv(k+1) = f;
      f1 = f0;
      f0 = f;
    end;
  else;
    if (xa <= 5.8) [v0,x,pd0] = dvsa(v0,x,pd0); end;
    if (xa > 5.8) [v0,x,pd0] = dvla(v0,x,pd0); end;
    dv(0+1) = pd0;
    m = 100+na;
    f1 = 0.0d0;
    f0 = 1.0d-30;
    for  k = m:-1:0;
      f = x.*f0+(k-v0+1.0d0).*f1;
      if (k <= na) dv(k+1) = f; end;
      f1 = f0;
      f0 = f;
    end;
    s0 = pd0./f;
    for  k = 0:na;
      dv(k+1) = s0.*dv(k+1);
    end;
  end;
end;
for  k = 0:na-1;
  v1 = abs(v0)+k;
  if (v >= 0.0d0) ;
    dp(k+1) = 0.5d0.*x.*dv(k+1)-dv(k+1+1);
  else;
    dp(k+1) = -0.5d0.*x.*dv(k+1)-v1.*dv(k+1+1);
  end;
end;
pdf = dv(na-1+1);
pdd = dp(na-1+1);
v   = vh;
return;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function [va,x,pd] = dvsa(va,x,pd);
%                for small argument
%       Input:   x  --- Argument
%                va --- Order
%       Output:  PD --- Dv(x)
%       Routine called: GAMMA for computing ג(x)
%       ===================================================
%
%

va0 = [];
ga0 = [];
g1  = [];
vt  = [];
g0  = [];
vm  = [];
gm  = [];
eps = 1.0d-15;
sq2 = sqrt(2.0d0);
ep  = exp(-.25d0.*x.*x);
va0 = 0.5d0.*(1.0d0-va);
if (va == 0.0) ;
  pd = ep;
else;
  if (x == 0.0) ;
    if (va0 <= 0.0&va0 == fix(va0)) ;
      pd = 0.0d0;
    else;
      [va0,ga0] = gamma(va0,ga0);
      pd = sqrt(pi)./(2.0d0.^(-.5d0.*va).*ga0);
    end;
  else;
    [dumvar1,g1] = gamma(-va,g1);
    a0 = 2.0d0.^(-0.5d0.*va-1.0d0).*ep./g1;
    vt = -.5d0.*va;
    [vt,g0] = gamma(vt,g0);
    pd = g0;
    r  = 1.0d0;
    for  m = 1:250;
      vm = .5d0.*(m-va);
      [vm,gm] = gamma(vm,gm);
      r  = -r.*sq2.*x./m;
      r1 = gm.*r;
      pd = pd+r1;
      if (abs(r1) < abs(pd).*eps) break; end;
    end;
    pd = a0.*pd;
  end;
end;
return;
end


function [va,x,pd]=dvla(va,x,pd);

%                for large argument
%       Input:   x  --- Argument
%                va --- Order
%       Output:  PD --- Dv(x)
%       Routines called:
%             (1) VVLA for computing Vv(x) for large |x|
%             (2) GAMMA for computing ג(x)
%       ====================================================



%
%
%
%
x1=[];vl=[];gl=[];
pi=3.141592653589793d0;
eps=1.0d-12;
ep=exp(-.25.*x.*x);
a0=abs(x).^va.*ep;
r=1.0d0;
pd=1.0d0;
for  k=1:16;
r=-0.5d0.*r.*(2.0.*k-va-1.0).*(2.0.*k-va-2.0)./(k.*x.*x);
pd=pd+r;
if (abs(r./pd) < eps) break; end;
end;
pd=a0.*pd;
if (x < 0.0d0) ;
x1=-x;
[va,x1,vl]=vvla(va,x1,vl);
[dumvar1,gl]=gamma(-va,gl);
pd=pi.*vl./gl+cos(pi.*va).*pd;
end;
return;
end


function [va,x,pv]=vvla(va,x,pv);

%                for large argument
%       Input:   x  --- Argument
%                va --- Order
%       Output:  PV --- Vv(x)
%       Routines called:
%             (1) DVLA for computing Dv(x) for large |x|
%             (2) GAMMA for computing ג(x)
%       ===================================================



%
%
%
%
x1=[];pdl=[];gl=[];
pi=3.141592653589793d0;
eps=1.0d-12;
qe=exp(0.25.*x.*x);
a0=abs(x).^(-va-1.0d0).*sqrt(2.0d0./pi).*qe;
r=1.0d0;
pv=1.0d0;
for  k=1:18;
r=0.5d0.*r.*(2.0.*k+va-1.0).*(2.0.*k+va)./(k.*x.*x);
pv=pv+r;
if (abs(r./pv) < eps) break; end;
end;
pv=a0.*pv;
if (x < 0.0d0) ;
x1=-x;
[va,x1,pdl]=dvla(va,x1,pdl);
[dumvar1,gl]=gamma(-va,gl);
dsl=sin(pi.*va).*sin(pi.*va);
pv=dsl.*gl./pi.*pdl-cos(pi.*va).*pv;
end;
return;
end


function [x,ga]=gamma(x,ga);

%       Input :  x  --- Argument of ג(x)
%                       ( x is not equal to 0,-1,-2,תתת)
%       Output:  GA --- ג(x)
%       ==================================================


%
%
%
g=zeros(26,1);

pi=3.141592653589793d0;
if (x == fix(x)) ;
if (x > 0.0d0) ;
ga=1.0d0;
m1=x-1;
for  k=2:m1;
ga=ga.*k;
end;
else;
ga=1.0d+300;
end;
else;
if (abs(x) > 1.0d0) ;
z=abs(x);
m=fix(z);
r=1.0d0;
for  k=1:m;
r=r.*(z-k);
end;
z=z-m;
else;
z=x;
end;
g=[1.0d0,0.5772156649015329d0,-0.6558780715202538d0,-0.420026350340952d-1,0.1665386113822915d0,-.421977345555443d-1,-.96219715278770d-2,.72189432466630d-2,-.11651675918591d-2,-.2152416741149d-3,.1280502823882d-3,-.201348547807d-4,-.12504934821d-5,.11330272320d-5,-.2056338417d-6,.61160950d-8,.50020075d-8,-.11812746d-8,.1043427d-9,.77823d-11,-.36968d-11,.51d-12,-.206d-13,-.54d-14,.14d-14,.1d-15];
gr=g(26);
for  k=25:-1:1;
gr=gr.*z+g(k);
end;
ga=1.0d0./(gr.*z);
if (abs(x) > 1.0d0) ;
ga=ga.*r;
if (x < 0.0d0) ga=-pi./(x.*ga.*sin(pi.*x)); end;
end;
end;
return;
end
