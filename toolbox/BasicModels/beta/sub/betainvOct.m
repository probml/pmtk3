function inv = betainvOct (x, a, b)
%% This is a replacement function for stats toolbox betainv 
% It is an adaptation of the betainv function in Octave written by KH
% <Kurt.Hornik@wu-wien.ac.at>, released under the GNU General Public
% License version 3. It was modified to make it Matlab compatible, and to
% use betacdfPMTK and betaProb instead of betacdf, and betapdf. 
%%

% This file is from pmtk3.googlecode.com

sz = size (x);
inv = zeros (sz);
k = find ((x < 0) | (x > 1) | ~(a > 0) | ~(b > 0) | isnan (x));
if (any (k))
    inv (k) = NaN;
end
k = find ((x == 1) & (a > 0) & (b > 0));
if (any (k))
    inv (k) = 1;
end
k = find ((x > 0) & (x < 1) & (a > 0) & (b > 0));
if (any (k))
    if (~isscalar(a) || ~isscalar(b))
        a = a (k);
        b = b (k);
        y = a ./ (a + b);
    else
        y = a / (a + b) * ones (size (k));
    end
    x = x (k); 
    if (isa (y, 'single'))
        myeps = eps ('single');
    else
        myeps = eps;
    end
    l = find (y < myeps);
    if (any (l))
        y(l) = sqrt (myeps) * ones (length (l), 1);
    end
    l = find (y > 1 - myeps);
    if (any (l))
        y(l) = 1 - sqrt (myeps) * ones (length (l), 1);
    end
    y_old = y;
    for i = 1 : 10000
        h     = (betacdfPMTK (y_old, a, b) - x) ./ betaProb (y_old, a, b);
        y_new = y_old - h;
        ind   = find (y_new <= myeps);
        if (any (ind))
            y_new (ind) = y_old (ind) / 10;
        end
        ind = find (y_new >= 1 - myeps);
        if (any (ind))
            y_new (ind) = 1 - (1 - y_old (ind)) / 10;
        end
        h = y_old - y_new;
        if (max (abs (h)) < sqrt (myeps))
            break;
        end
        y_old = y_new;
    end
    
    inv (k) = y_new;
end
end
