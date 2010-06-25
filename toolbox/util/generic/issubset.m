function bool = issubset(A, B)
% Return true iff A is a subset of B
% e.g.
% issubset(1:3,1:5)
% ans =
%      1
%
bool = all(ismember(A, B));

end