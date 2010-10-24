function paracylTest()
%% Compare the speed of different implementations of the paracyl function

% This file is from pmtk3.googlecode.com

z=-10:0.5:10;
x=-10.5:.5:10;

as = [0.01 0.75 1];
bs = ones(1,4);
compare = true;
if true
    tic
    outNEG = zeros(numel(as), numel(z));
    for k=1:length(z)
        for i=1:length(as)
            outNEG(i, k) = minidx(.5*(z(k)-x).^2+normalExpGammaNeglogpdf(x, as(i), bs(i)));
        end
    end
    toc
end

tic
outNEGFast = zeros(numel(as), numel(z));
for k=1:length(z)
    for i=1:length(as)
        outNEGFast(i, k) = minidx(.5*(z(k)-x).^2+normalExpGammaNeglogpdfFast(x, as(i), bs(i)));
    end
end
toc

if compare, assert(approxeq(outNEG, outNEGFast));end



end



function out=normalExpGammaNeglogpdf(z,shape,scale)
% gamma^2 = c = scale
lambda = shape;
gamma = sqrt(scale);
out = zeros(1, length(z));
for k=1:length(z)
    out(k)=-z(k)^2/(4*gamma^2)-log(mpbdv(-2*(lambda+1/2),abs(z(k))/gamma));
end
end


function out=normalExpGammaNeglogpdfFast(z,shape,scale)
% gamma^2 = c = scale
lambda = shape;
gamma = sqrt(scale);
out = -z.^2/(4*gamma^2)-log(paracyl(-2*(lambda+1/2), abs(z)./gamma));
end
