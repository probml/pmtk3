function pdf = paracyl(V, X)
% A more efficient implementation of the parabolic cylinder function
% Input:   x --- Argument of Dv(x)
%          v --- Order of Dv(x)
%
% see mpbdv for details
%
% PMTKmodified Matt Dunham 
% Sped up by a factor of 11
%
% PDF is of size length(V)-by-length(X)

% This file is from pmtk3.googlecode.com



pdf = zeros(numel(V), numel(X));
for i=1:numel(V)
    for j =1:numel(X)
        v  = V(i);
        x  = X(j);
        dv = zeros(101, 1);
        xa = abs(x);
        v  = v + sign(v);
        nv = fix(v);
        v0 = v-nv;
        na = abs(nv);
        ep = exp(-.25*x^2);
        if (na >= 1)
            ja=1;
        end
        if (v >= 0)
            if (v0 == 0)
                pd0 = ep;
                pd1 = x*ep;
            else
                for l = 0:ja;
                    v1 = v0+l;
                    if (xa <= 5.8)
                        pd1 = dvsa(v1, x);
                    else
                        pd1 = dvla(v1, x);
                    end
                    if (l == 0)
                        pd0 = pd1;
                    end
                end
            end
            dv(1) = pd0;
            dv(2) = pd1;
            for  k = 2:na;
                pdf(i, j) = x*pd1-(k+v0-1)*pd0;
                dv(k+1) = pdf(i, j);
                pd0 = pd1;
                pd1 = pdf(i, j);
            end
        else
            if (x <= 0)
                if (xa <= 5.8);
                    pd0 = dvsa(v0, x);
                    v1 = v0-1;
                    pd1 = dvsa(v1, x);
                else
                    pd0 = dvla(v0, x);
                    v1 = v0-1;
                    pd1 = dvla(v1, x);
                end
                dv(1) = pd0;
                dv(2) = pd1;
                for  k = 2:na;
                    pd = (-x*pd1+pd0)/(k-1-v0);
                    dv(k+1) = pd;
                    pd0 = pd1;
                    pd1 = pd;
                end
            elseif (x <= 2)
                v2 = nv+v0;
                if (nv == 0)
                    v2 = v2-1;
                end
                nk = fix(-v2);
                f1 = dvsa(v2, x);
                v1 = v2+1;
                f0 = dvsa(v1, x);
                dv(nk+1) = f1;
                dv(nk-1+1) = f0;
                for  k = nk-2:-1:0;
                    f = x*f0+(k-v0+1)*f1;
                    dv(k+1) = f;
                    f1 = f0;
                    f0 = f;
                end
            else
                if (xa <= 5.8)
                    pd0 = dvsa(v0, x);
                else
                    pd0 = dvla(v0, x);
                end
                dv(1) = pd0;
                m = 100+na;
                f1 = 0;
                f0 = 1e-30;
                fFull = zeros(1, m+1);
                for  k = m:-1:0;
                    fFull(k+1) = x*f0+(k-v0+1)*f1;
                    f1 = f0;
                    f0 = fFull(k+1);
                end
                s0 = pd0/fFull(1);
                dv(na:-1:1) = s0*fFull(na:-1:1);
            end
        end
        pdf(i, j) = dv(max(na, 1));
    end
end
end

function pd = dvsa(va, x)

sq2 = sqrt(2);
ep  = exp(-.25*x^2);
va0 = 0.5*(1-va);
if (va == 0)
    pd = ep;
else
    if (x == 0)
        if (va0 <= 0 && va0 == fix(va0))
            pd = 0;
        else
            ga0 = gamma(va0);
            pd = sqrt(pi)/(2^(-.5*va)*ga0);
        end
    else
        a0 = 2^(-0.5*va-1)*ep/gamma(-va);
        pd = gamma( -.5*va);
        r  = 1;
        maxsize = 250;
        m = 1;
        gm = gamma(0.5*((1:maxsize)-va));
        while true
            r  = -r.*sq2*x/m;
            r1 = gm(m)*r;
            pd = pd+r1;
            if (abs(r1) < abs(pd)*1e-15) || m > maxsize;
                break
            end
            m = m+1;
        end
        pd = a0*pd;
    end
end
end

function pd = dvla(va, x)

ep=exp(-.25*x^2);
a0=abs(x)^va*ep;
r=1;
pd=1;
for  k=1:16;
    r=-0.5*r*(2*k-va-1)*(2*k-va-2)/(k*x^2);
    pd=pd+r;
    if (abs(r/pd) < 1e-12)
        break
    end
end
pd=a0*pd;
if (x < 0)
    x1=-x;
    vl = vvla(va, x1);
    gl=gamma(-va);
    pd=pi*vl/gl+cos(pi*va)*pd;
end

end

function pv = vvla(va, x)

qe=exp(0.25*x^2);
a0=abs(x)^(-va-1)*sqrt(2/pi)*qe;
r=1;
pv=1;
for  k=1:18
    r=0.5*r*(2*k+va-1)*(2*k+va)/(k*x^2);
    pv=pv+r;
    if (abs(r/pv) < 1e-12)
        break
    end
end
pv=a0*pv;
if (x < 0)
    pv = (sin(pi*va)^2)*gamma(-va)/pi*dvla(va, -x)-cos(pi*va)*pv;
end

end 
