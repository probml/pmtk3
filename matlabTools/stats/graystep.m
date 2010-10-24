function  H = graystep(B, d)
%% Cycle a logical vector d steps through the Gray cyclic binary codes
%  H = graystep(B, d)  takes row  B  of logical values  (0  or  1)
%  through one step forward,  if  d ~= 0 ,  or otherwise backward,
%  through the  Gray Cyclic Binary Codes.  Only one element of  H
%  differs from the corresponding element of  BÊ,  and repeated
%  invocations  B = graystep(B, d)  step through all  2^length(B)
%  different codes.  Graystep(B, d)  changes any nonzero element
%  of  B  different from  1  to  1  and then turns  B  into a row
%  vector before doing anything else.  To convert  H  into an
%  integer  k  like one of those in column  grays(length(H))  let
%  k = H*cumprod([1;ones(length(G)-1,1)*2])  if  length(H)Ê< 54 .
%  See also  grays.m,  gray2int.m  and  int2gray.m .  Graystep
%  is adapted from  J. Boothroyd's Algorithm #246  on  p. 701 of
%  Comm. ACM vol. 7 (1964).               W. Kahan,  8 July 2007

% This file is from pmtk3.googlecode.com


H = (B(:)' ~= 0);
n = length(H);
j = n+1;
d = (d ~= 0);
for i = n:-1:1
    if  H(i)
        d = ~(d);
        j = i;
    end
end  %...  for  i ...  so  H(j)  is first element not  0
if  d
    H(1) = ~(H(1));
else
    if  (j < n)
        H(j+1) = ~(H(j+1));
    else
        H(n) = ~(H(n));
    end
end  %...  if  d
end
