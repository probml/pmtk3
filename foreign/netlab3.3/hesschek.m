function h = hesschek(net, x, t)
%HESSCHEK Use central differences to confirm correct evaluation of Hessian matrix.
%
%	Description
%
%	HESSCHEK(NET, X, T) takes a network data structure NET, together with
%	input and target data matrices X and T, and compares the evaluation
%	of the Hessian matrix using the function NETHESS and using central
%	differences with the function NETERR.
%
%	The optional return value H is the Hessian computed using NETHESS.
%
%	See also
%	NETHESS, NETERR
%

%	Copyright (c) Ian T Nabney (1996-2001)

w0 = netpak(net);
nwts = length(w0);
h = nethess(w0, net, x, t);

w = w0;
hcent = zeros(nwts, nwts);
h1 =  0.0; h2 =  0.0; h3 =  0.0; h4 = 0.0;
epsilon = 1.0e-4;
fprintf(1, 'Checking Hessian ...\n\n');
for k = 1:nwts;
  for l = 1:nwts;
    if(l == k)
      w(k) = w0(k) + 2.0*epsilon;
      h1 = neterr(w, net, x, t);
      w(k) = w0(k) - 2.0*epsilon;
      h2 = neterr(w, net, x, t);
      w(k) = w0(k);
      h3 = neterr(w, net, x, t);
      hcent(k, k) = (h1 + h2 - 2.0*h3)/(4.0*epsilon^2);
    else
      w(k) = w0(k) + epsilon;
      w(l) = w0(l) + epsilon;
      h1 = neterr(w, net, x, t);
      w(k) = w0(k) - epsilon;
      w(l) = w0(l) - epsilon;
      h2 = neterr(w, net, x, t);
      w(k) = w0(k) + epsilon;
      w(l) = w0(l) - epsilon;
      h3 = neterr(w, net, x, t);
      w(k) = w0(k) - epsilon;
      w(l) = w0(l) + epsilon;
      h4 = neterr(w, net, x, t);
      hcent(k, l) = (h1 + h2 - h3 - h4)/(4.0*epsilon^2);
      w(k) = w0(k);
      w(l) = w0(l);
    end
  end
end

fprintf(1, '   analytical    numerical       delta\n\n');
temp = [h(:), hcent(:), (h(:) - hcent(:))];
fprintf(1, '%12.6f  %12.6f  %12.6f\n', temp');