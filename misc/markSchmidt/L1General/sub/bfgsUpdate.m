function [B,g_prev,w_prev] = bfgsUpdate(B,w,w_prev,g,g_prev,scale)
% Updates BFGS approximation B with corrections y and s
%
% if scale is 1, use scaled identity matrix instead of B
% (typically you will call it with scale==1 on the 2nd iteration,
%   and scale==0 on subsequent iterations)

y = g-g_prev;
s = w-w_prev;
            
ys = y'*s;

if ys > 1e-10
    if scale
        B = ((y'*y)/(y'*s)*eye(length(w)));
    end
    B = B + (y*y')/(y'*s) - (B*s*s'*B)/(s'*B*s);
else
    fprintf('Skipping Update\n');
end

w_prev = w;
g_prev = g;
