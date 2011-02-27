%% Demo of the pagerank algorithm, based on code by Cleve Moler
% See also pagerankDemoMoler, pagerankDemoGui, surfer, pagerankpow
%%
%% 6 node web example

% This file is from pmtk3.googlecode.com

i = [ 2 6 3 4 4 5 6 1 1];
j = [ 1 1 2 2 3 3 3 4 6];
n = 6;
G  = sparse(i,j,1,n,n); % sparse n x n matrix with 1's in specified positions

c = sum(G,1);
k = find(c~=0); % non zero outdegree
D = sparse(k,k,1./c(k),n,n);
e = ones(n,1);
I = speye(n,n);
p = 0.85;

%% Find the stationary distribution
pi = normalize((I - p*G*D)\e);
fprintf('exact pi\n');  disp(pi(:)')

figure; bar(pi);printPmtkFigure('smallwebPagerank'); 


%% Power method
fprintf('pi over time using power method\n');
format compact
pi = e/n;
z = ((1-p)*(c~=0) + (c==0))/n;
A = p*G*D + e*z;
for i=1:10
  pi = normalize(A*pi); 
  disp(pi')
end

%% Matrix free power method
[pi,cnt] = pagerankpow(G);
fprintf('matrix free power method\n'); disp(pi(:)')


%% Now run it on the Harvard web site
loadData('harvard500');
figure;spy(G);
printPmtkFigure('harvard500spy'); 
tic
[pi,cnt] = pagerankpow(G);
toc
figure;bar(pi);set(gca,'xlim',[-10 510]);set(gca,'ylim',[0 0.02])
printPmtkFigure('harvard500pagerank'); 
[pi,ndx] = sort(pi, 'descend');
celldisp(U(ndx(1:3)))



