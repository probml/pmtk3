function M = mkSymmetric(M)

%Mtest = M;    
Mt = M';
M(M==0) = Mt(M==0);
    
%     
% n = size(Mtest,1);
% for i=1:n
%   for j=1:n
%     if Mtest(i,j)==0, Mtest(i,j)=Mtest(j,i);
%     end
%   end
% end
% assert(isequal(M,Mtest));    
% 

%T = triu(M);
%L = tril(M);
%M =T | T' | L | L';
%M = (M+M')/2;
