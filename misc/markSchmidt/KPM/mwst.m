function [tt] = mwst(ww,rootnode)
% minimum weight spanning tree
% returns the minimum weight spanning tree given edge weights ww
% tree(i) tells you the parent of node i except tree(rootnode)=0
% if rootnode is absent, it is set to 1 by default
% for maximum weight spanning tree use mwst(-ww)
%
% Written by Sam Roweis

N = size(ww,1);

if(nargin<2) rootnode=[]; end
if(isempty(rootnode) | rootnode<1 | rootnode>N) rootnode=1; end

wwtmp = []; pii=[]; pjj=[];
for nn=1:N
  wwtmp = [wwtmp,ww(nn,(nn+1):end)];
  pii = [pii,nn*ones(1,N-nn)]; pjj = [pjj,(nn+1):N];
end

nlinks=0; tstpos=1; tt=zeros(1,N);
clump = 1:N; 
links=sparse([],[],[],N,N,2*N);

[wwtmp,wwii] = sort(wwtmp);
pii=pii(wwii); pjj=pjj(wwii);


while(nlinks<(N-1))

  ii=pii(tstpos); jj=pjj(tstpos);

  if(clump(ii)~=clump(jj))
    clump(find(clump==clump(ii)|clump==clump(jj)))= min(clump(ii),clump(jj));
    nlinks=nlinks+1;
    links(ii,jj)=1; links(jj,ii)=1;
    %fprintf(1,'Accepting link (%d,%d)\n',ii,jj);
  end

  tstpos=tstpos+1;

end

plist=[rootnode];
while(~isempty(plist))
  ff=find(links(plist(1),:));
  tt(ff)=plist(1);
  links(plist(1),ff)=0; links(ff,plist(1))=0;
  plist=[plist(2:end),ff];
end

