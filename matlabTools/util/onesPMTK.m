function T = onesPMTK(sizes)
% Like the built-in ones, except onesPMTK(k) produces a k*1 vector instead of a k*k matrix

% This file is from pmtk3.googlecode.com


if isempty(sizes)
    T = 1;
elseif length(sizes)==1
    T = ones(sizes, 1);
else
  T = ones(sizes(:)');
end

end
