function [p_xy] = complexProject(xy,tau)

z = complex(xy(1:length(xy)/2),xy(length(xy)/2+1:end));
p_z = sign(z).*projectRandom2C(abs(z),tau);
p_xy = [real(p_z);imag(p_z)];