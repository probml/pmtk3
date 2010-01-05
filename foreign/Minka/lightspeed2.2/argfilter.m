function args = argfilter(args,keep)
%ARGFILTER  Remove unwanted arguments.
% ARGFILTER(ARGS,KEEP), where ARGS = {'arg1',value1,'arg2',value2,...},
% returns a new argument list where only the arguments named in KEEP are
% retained.  KEEP is a character array or cell array of strings.

% Written by Tom Minka

if ischar(keep)
  keep = cellstr(keep);
end
i = 1;
while i < length(args)
  if ~ismember(args{i},keep)
    args = args(setdiff_sorted(1:length(args),[i i+1]));
  else
    i = i + 2;
  end
end
