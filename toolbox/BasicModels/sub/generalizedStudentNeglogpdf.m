function out=generalizedStudentNeglogpdf(w,a,b)

% This file is from pmtk3.googlecode.com

out = -log(a) + log(2*b) + (a+1)*log(abs(w)/b + 1);

end
