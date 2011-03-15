function Ximpute = mixGaussDiscreteImpute( model, X )
% Impute NaNs in a matrix of mixed cts/ discrete data
% See mixGaussDiscreteFitEm for details of the model

% This file is from pmtk3.googlecode.com


%PMTKauthor Hannes Bretschneider

labels = model.labels;
types = model.types;
C = size(model.beta,1);
iscont = (types=='c');
isdiscr = ~iscont;
mixweight = model.mixweight;
K = length(model.mixweight);
[n,d] = size(X);
dCont = sum(iscont);
dDiscr = sum(isdiscr);
XC = X(:,iscont);
XD = X(:,isdiscr);

for j=1:dDiscr
    x = XD(:,j);
    l = labels{j};
    x(~isnan(x)) = arrayfun(@(a)find(l==a),x(~isnan(x)));
    XD(:,j) = x;
end


for i=1:n
  hidNodes = find(isnan(X(i,:)));
  hidNodesC = find(isnan(XC(i,:)));
  hidNodesD = find(isnan(XD(i,:)));
  m = length(hidNodes);
  mC = length(hidNodesC);
  mD = length(hidNodesD);
  if isempty(hidNodes), continue, end;
  visNodesC = find(~isnan(XC(i,:)));
  visValuesC = XC(i,visNodesC);
  visNodesD = find(~isnan(XD(i,:)));
  visValuesD = XD(i,visNodesD);
  modelH.mu = NaN(mC,K);
  modelH.Sigma = NaN(mC,K);
  betaW = zeros(C,dDiscr);
  for k=1:K
    modelH.mu(:,k) = model.mu(hidNodesC,k);
    pGauss = arrayfun(@(i)gauss(model.mu(visNodesC(i),k),...
        model.Sigma(visNodesC(i),k), visValuesC(i)),1:length(visNodesC));
    pDiscr = arrayfun(@(i)model.beta(visValuesD(i),visNodesD(i),k),...
        1:length(visValuesD));
    ri(k) = mixweight(k)*prod(pGauss)*prod(pDiscr);
    betaW = betaW + ri(k)*model.beta(:,:,k);
  end
  ri = normalize(ri);
  XC(i, hidNodesC) =  rowvec(ri * modelH.mu');
  XD(i, hidNodesD) = pickModeClass(betaW(:,hidNodesD));
end

for j=1:dDiscr
    x = XD(:,j);
    l = labels{j};
    x = l(x);
    XD(:,j) = x;
end

Ximpute = NaN(n,d);
Ximpute(:,iscont) = XC;
Ximpute(:,isdiscr) = XD;

end

function modeClass = pickModeClass(beta)
beta = beta';
mode = max(beta,[],2);
beta = bsxfun(@minus, beta, mode);
beta = (beta==0);
modeClass = arrayfun(@(i)find(beta(i,:)==1,1),1:size(beta,1));
end
