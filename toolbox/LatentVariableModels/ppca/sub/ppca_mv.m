function [C, ss, M, X,Ye] = ppca_mv(Ye,d,dia)
% Implements probabilistic PCA for data with missing values
% using a factorizing distribution over hidden states and hidden observations.
%
%  - The entries in Ye that equal NaN are assumed to be missing. - 
%
% [C, ss, M, X, Ye ] = ppca_mv(Y,d,dia)
%
% Y   (N by D)  N data vectors
% d   (scalar)  dimension of latent space
% dia (binary)  if 1: printf objective each step
%
% ss  (scalar)  isotropic variance outside subspace
% C   (D by d)  C*C' +I*ss is covariance model, C has scaled principal directions as cols.
% M   (D by 1)  data mean
% X   (N by d)  expected states
% Ye  (N by D)  expected complete observations (interesting if some data is missing)
%
%PMTKauthor Jakob Verbeek
%PMTKurl http://lear.inrialpes.fr/~verbeek
%PMTKdate 2006

% This file is from pmtk3.googlecode.com



[N D]       = size(Ye); % N observations in D dimensions
threshold   = 1e-4;     % minimal relative change in objective funciton to continue    
hidden      = isnan(Ye); 
missing     = sum(hidden(:));

M = zeros(1,D);  % compute data mean and center data
if missing; 
    for i=1:D;  
        M(i) = mean(Ye(~hidden(:,i),i)); 
    end;
else
    M    = mean(Ye);                 
end;
Ye = Ye - repmat(M,N,1);

if missing
    Ye(hidden)=0; 
end

% =======     Initialization    ======
C     = randn(D,d);
CtC   = C'*C;
X     = Ye * C * inv(CtC);
recon = X*C'; recon(hidden) = 0;
ss    = sum(sum((recon-Ye).^2)) / (N*D-missing);

count = 1; 
old   = Inf;
while count          %  ============ EM iterations  ==========      
   
    Sx = inv( eye(d) + CtC/ss );    % ====== E-step, (co)variances   =====
    ss_old = ss;
    if missing
        proj = X*C'; 
        Ye(hidden) = proj(hidden); 
    end  
    X = Ye*C*(Sx/ss);          % ==== E step: expected values  ==== 
    
    SumXtX = X'*X;                              % ======= M-step =====
    C      = (Ye'*X)  / (SumXtX + N*Sx );    
    CtC    = C'*C;
    ss     = ( sum(sum( (X*C'-Ye).^2 )) + N*sum(sum(CtC.*Sx)) + missing*ss_old ) /(N*D); 
    
    objective = N*D + N*(D*log(ss) +trace(Sx)-log(det(Sx)) ) +trace(SumXtX) -missing*log(ss_old);           
           
    rel_ch    = abs( 1 - objective / old );
    old       = objective;
    
    count = count + 1;
    if ( rel_ch < threshold) && (count > 5); count = 0;end
    if dia; fprintf('Objective:  %.2f    relative change: %.5f \n',objective, rel_ch ); end
    
end             %  ============ EM iterations  ==========


C = orth(C);
[vecs,vals] = eig(cov(Ye*C));
[vals,ord] = sort(diag(vals),'descend');
vecs = vecs(:,ord);

C = C*vecs;
X = Ye*C;
 
% add data mean to expected complete data
Ye = Ye + repmat(M,N,1);

end
