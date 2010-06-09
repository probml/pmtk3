function [sample] = sampleLogisticInd(m,v,y)
s = sign(y-.5);
U=rand;
sample = logisticInversecdf(U,m,v);
while sign(sample)~=s
    if s > 0
        U = 1-rand*(1-U);
        if U == 1
            fprintf('Numerically Unstable\n');
            pause;
            break;
        end
        sample = logisticInversecdf(U,m,v);
    else
        U = rand*U;
        if U == 0
            fprintf('Numerically Unstable\n');
            break;
        end
        sample = logisticInversecdf(U,m,v);
    end
end
