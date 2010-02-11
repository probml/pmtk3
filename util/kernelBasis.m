function K = kernelBasis(X1, X2, kernel, kernelpar)
% K(i,j) = Kernel(X1(i,:), X2(j,:))
% 
%   K = calc_Kernel(X1, X2, kernel, kernelpar)
%   kernel and kernelpar select the kernel function and its
%   parameters. X1 and X2 contain one example per row. If X1 is of size
%   [M, nin] and X2 is of size [N, nin], K will be a matrix
%   [M, N]. K(i,j) is the result of the kernelfunction for inputs X1(i,:)
%   and X2(j,:).
%   Currently the only valid kernel functions are
%   kernel = 'linear' 
%       inner product
%   kernel = 'poly'
%       (1+inner product)^kernelpar(1)
%   kernel = 'rbf'
%       radial basis function, common length scale for all inputs is
%       kernelpar(1), scaled with the number of inputs nin
%       K = exp(-sum((X1i-X2i)^2)/(kernelpar(1)*nin))
%   kernel = 'rbffull'
%       radial basis function, different length scale for each input.
%       If kernelpar is a vector of length nin
%       K = exp(-sum((X1i-X2i)^2*kernelpar(i))/nin)
%       If kernelpar is a vector of length nin+1
%       K = exp(kernelpar(end)-sum((X1i-X2i)^2*kernelpar(i))/nin)
%       If kernelpar is a matrix of size [nin, nin]
%       K = exp(-(X1-X2)*kernelpar*(X1-X2)'/nin)

%#author Anton Schwaighofer
%#modified Balaji Krishnapuram 

if (size(X1,2)~=size(X2,2))
    error('X1 & X2 differ in dimensionality!!');
end

[N1, d] = size(X1);
[N2, nin] = size(X2);

switch kernel
 case 'direct'
  K = X1;
  case 'cosine'
    for i=1:N1        
        X1(i,:)=X1(i,:)./norm(X1(i,:));
    end
    for i=1:N2        
        X2(i,:)=X2(i,:)./norm(X2(i,:));
    end
    
    K = X1*X2';
  case 'linear'
    K = X1*X2';
  case 'poly'
    K = (1+X1*X2').^kernelpar(1);
  case 'rbf'
    dist2 = repmat(sum((X1.^2)', 1), [N2 1])' + ...
            repmat(sum((X2.^2)',1), [N1 1]) - ...
            2*X1*(X2');
    K = exp(-dist2/(nin*kernelpar(1)));%exp(-dist2/(nin*kernelpar(1)));
  case 'rbffull'
    bias = 0;
    if any(all(repmat(size(kernelpar), [4 1]) == ...
               [d 1; 1 d; d+1 1; 1 d+1], 2), 1),
      weights = diag(kernelpar(1:d));
      if length(kernelpar)>d,
        bias = kernelpar(length(kernelpar));
      end
    elseif all(size(kernelpar)==[d d]),
      weights = kernelpar;
    else
      error('Size of kernelpar does not match the chosen kernel ''rbffull''');
    end
    dist2 = (X1.^2)*weights*ones([d N2]) + ...
            ones([N1 d])*weights*(X2.^2)' - ...
            2*X1*weights*(X2');
    K = exp(bias-dist2/nin);
  otherwise
    error('Unknown kernel function');
end

% Xa=sqrt(diag(K));
% K=K./(Xa*Xa');

%K = double(K);
% Convert to full matrix if inputs are sparse





