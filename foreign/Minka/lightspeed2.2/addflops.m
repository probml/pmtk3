function f = addflops(fl)
% ADDFLOPS   Increment the global flopcount variable.
% ADDFLOPS(fl) is equivalent to FLOPS(FLOPS+FL), but more efficient.

global flopcount;
if ~isempty(flopcount)
  flopcount = flopcount + fl;
end
