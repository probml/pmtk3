%%
bigdom = [1 2];
Tbig = reshape([1 2 3 4], [2 2]);

%smalldom = [1 2];
%Tsmall = reshape([5 6 7 8], [2 2]);

smalldom = [2 1];
Tsmall = reshape([5 6 7 8], [2 2]);

%smalldom = [1];
%Tsmall = reshape([5 6], [2 1]);


T = bsxTable(@times, Tbig, Tsmall, bigdom, smalldom);

TT = zeros(2,2);
for i=1:2
  for j=1:2
    %TT(i,j) = Tbig(i,j) * Tsmall(i,j);
    TT(i,j) = Tbig(i,j) * Tsmall(j,i);
    %TT(i,j) = Tbig(i,j) * Tsmall(i);
  end
end

assert(approxeq(T, TT))

 
%%
bigdom = [3 2 1];
Tbig = reshape(1:8, [2 2 2]);
bigsz = [2 2 2];

smalldom = [3 1];
Tsmall = reshape([5 6 7 8], [2 2]);

T = bsxTable(@times, Tbig, Tsmall, bigdom, smalldom);

TT = zeros(2,2,2); % TT(3,2,1) = Tbig(3,2,1) * Tsmall(3,1)
for i=1:2
  for j=1:2
    for k=1:2
      TT(k,j,i) = Tbig(k,j,i) * Tsmall(k,i);
    end
  end
end
assert(approxeq(T, TT))

%smallT = margTable(bigT, bigdom, bigsz, onto, maximize)

% Tsmall2(3) = sum_{1.2} TT(3,2,1)
onto = 3;
Tsmall2 = margTable(TT, bigdom, bigsz, onto);
TT2 = zeros(2,1);
for i=1:2
  for j=1:2
    for k=1:2
      TT2(k) = TT2(k) + TT(k,j,i);
    end
  end
end
assert(approxeq(TT2, Tsmall2))



% Tsmall3(2) = sum_{1,3} TT(3,2,1)
onto = 2;
Tsmall3 = margTable(TT, bigdom, bigsz, onto);
TT3 = zeros(2,1);
for i=1:2
  for j=1:2
    for k=1:2
      TT3(j) = TT3(j) + TT(k,j,i);
    end
  end
end
assert(approxeq(TT3, Tsmall3))


