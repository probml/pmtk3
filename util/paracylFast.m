function pdf = paracylFast(v, x) 
% Parabolic cylinder function
    
    dv = zeros(101, 1);
    dp = zeros(101, 1); 
    xa  = abs(x);
    v   = v + sign(v);
    nv  = fix(v);
    v0  = v-nv;
    na  = abs(nv);
    ep  = exp(-.25.*x.*x);
    if (na >= 1) 
        ja=1; 
    end
    if (v >= 0) 
        if (v0 == 0)
            pd0 = ep;
            pd1 = x.*ep;
        else
            for l = 0:ja;
                v1 = v0+l;
                if (xa <= 5.8) 
                    pd1 = dvsa(v1, x); 
                end
                if (xa > 5.8) 
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
            pdf = x.*pd1-(k+v0-1).*pd0;
            dv(k+1) = pdf;
            pd0 = pd1;
            pd1 = pdf;
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
                pd = (-x.*pd1+pd0)./(k-1-v0);
                dv(k+1) = pd;
                pd0 = pd1;
                pd1 = pd;
            end
        elseif (x <= 2);
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
                f = x.*f0+(k-v0+1).*f1;
                dv(k+1) = f;
                f1 = f0;
                f0 = f;
            end
        else
            if (xa <= 5.8) 
                pd0 = dvsa(v0, x); 
            end
            if (xa > 5.8) 
                pd0 = dvla(v0, x);
            end
            dv(1) = pd0;
            m = 100+na;
            f1 = 0;
            f0 = 1.0d-30;
            for  k = m:-1:0;
                f = x.*f0+(k-v0+1).*f1;
                if (k <= na) 
                    dv(k+1) = f; 
                end
                f1 = f0;
                f0 = f;
            end
            s0 = pd0./f;
            for  k = 0:na;
                dv(k+1) = s0.*dv(k+1);
            end
        end
    end
    for  k = 0:na-1;
        v1 = abs(v0)+k;
        if (v >= 0) ;
            dp(k+1) = 0.5.*x.*dv(k+1)-dv(k+1+1);
        else
            dp(k+1) = -0.5.*x.*dv(k+1)-v1.*dv(k+1+1);
        end
    end;
    pdf = dv(na-1+1);
end   
   
function pd = dvsa(va, x) 
    
    sq2 = sqrt(2);
    ep  = exp(-.25.*x.*x);
    va0 = 0.5*(1-va);
    if (va == 0) 
        pd = ep;
    else
        if (x == 0) 
            if (va0 <= 0 && va0 == fix(va0)) 
                pd = 0;
            else
                ga0 = gamma(va0);
                pd = sqrt(pi)./(2.^(-.5.*va).*ga0);
            end;
        else
            g1 = gamma(-va);
            a0 = 2.^(-0.5.*va-1).*ep./g1;
            vt = -.5.*va;
            g0 = gamma(vt);
            pd = g0;
            r  = 1;
            for  m = 1:250;
                vm = .5.*(m-va);
                gm = gamma(vm);
                r  = -r.*sq2.*x./m;
                r1 = gm.*r;
                pd = pd+r1;
                if (abs(r1) < abs(pd)*eps) 
                    break
                end
            end
            pd = a0.*pd;
        end
    end
end
    
function pd = dvla(va, x) 
    ep=exp(-.25.*x.*x);
    a0=abs(x).^va.*ep;
    r=1;
    pd=1;
    for  k=1:16;
        r=-0.5.*r.*(2.*k-va-1.0).*(2.*k-va-2)./(k.*x.*x);
        pd=pd+r;
        if (abs(r./pd) < eps) 
            break
        end
    end
    pd=a0.*pd;
    if (x < 0) 
        x1=-x;
        vl = vvla(va, x1);
        gl=gamma(-va);
        pd=pi.*vl./gl+cos(pi.*va).*pd;
    end
end    
   
function pv = vvla(va, x) 
    qe=exp(0.25.*x.*x);
    a0=abs(x).^(-va-1).*sqrt(2./pi).*qe;
    r=1;
    pv=1;
    for  k=1:18;
        r=0.5.*r.*(2.*k+va-1.0).*(2.*k+va)./(k.*x.*x);
        pv=pv+r;
        if (abs(r./pv) < eps)
            break; 
        end
    end
    pv=a0.*pv;
    if (x < 0);
        x1=-x;
        pdl = dvla(va, x1);
        gl=gamma(-va);
        dsl=sin(pi.*va).*sin(pi.*va);
        pv=dsl.*gl./pi.*pdl-cos(pi.*va).*pv;
    end
end 