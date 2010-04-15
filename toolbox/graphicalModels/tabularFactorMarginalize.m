function smallpot = tabularFactorMarginalize(bigpot, onto, maximize)
% Both bigpot ans smallpot are structs with fields, T, domain, sizes. 
% If maximize is true, (default = false), maximize rather than sum. 

if nargin < 3,
    maximize = false;
end
smallT = marg_table(bigpot.T, bigpot.domain, bigpot.sizes, onto, maximize);
smallpot = tabularFactorCreate(smallT, onto);

end