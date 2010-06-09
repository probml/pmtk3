function [lambda] = sampleLambda(r)
ok = 0;

while ~ok
    Y = randn;
    Y = Y*Y;
    Y = 1+(Y-sqrt(Y*(4*r+Y)))/(2*r);
    U = rand;

    if U <= 1/(1+Y)
        lambda = r/Y;
    else
        lambda = r*Y;
    end

    % Now, lambda ~ GIG(0.5,1,r^2)
    U = rand;

    if U > 4/3
        ok = rightmost_interval(U,lambda);
    else
        ok = leftmost_interval(U,lambda);
    end
end
end

function [OK] = rightmost_interval(U,lambda)
Z = 1;
X = exp(-.5*lambda);
j = 0;

while 1
    j = j + 1;
    Z = Z-((j+1)^2)*X^(((j+1)^2) - 1);

    if Z > U
        OK = 1;
        return;
    end

    j = j + 1;
    Z = Z+((j+1)^2)*X^(((j+1)^2) - 1);

    if Z < U
        OK = 0;
        return;
    end

end
end

function [OK] = leftmost_interval(U,lambda)
H = 0.5*log(2) + 2.5*log(pi) - 2.5*log(lambda) - (pi^2)/(2*lambda) + 0.5*lambda;
lU = log(U);
Z = 1;
X = exp((-pi^2)/(2*lambda));
K = lambda/pi^2;
j = 0;
while 1
    j = j + 1;
    Z = Z - K*X^((j^2)-1);

    if H + log(Z) > lU
        OK = 1;
        return;
    end

    j = j + 1;
    Z = Z + ((j+1)^2)*X^(((j+1)^2) -1);

    if H + log(Z) < lU
        OK = 0;
        return;
    end
end
end
