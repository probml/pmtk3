function M = mkSymmetric(M)
% Fill in 0 entries of a matrix with their "mirror image"

% This file is from pmtk3.googlecode.com

%Mtest = M; 

Mt = M';
M(M==0) = Mt(M==0);
    
if 0
n = size(Mtest,1);
 for i=1:n
   for j=1:n
     if Mtest(i,j)==0, Mtest(i,j)=Mtest(j,i);
     end
   end
 end
 assert(isequal(M,Mtest));    
end 

%T = triu(M);
%L = tril(M);
%M =T | T' | L | L';
%M = (M+M')/2;

end
