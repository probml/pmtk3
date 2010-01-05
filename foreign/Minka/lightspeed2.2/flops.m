function f = flops(fl)
% FLOPS         Get or set the global flopcount variable.
% FLOPS returns the current flopcount.
% FLOPS(F) sets flopcount to F.
%
% 0 flops: -x ' repmat
% 1 flop each: + - .* 
% 2 flops each: < > == ~=
% For complex numbers, + is 2 flops, * is 6 flops.
% col_sum(x) takes (rows(x)-1)*cols(x) flops (use FLOPS_COL_SUM).
% row_sum(x) takes rows(x)*(cols(x)-1) flops (use FLOPS_ROW_SUM).
% Use FLOPS_DIV for ./ 
% Use FLOPS_RANDNORM for randn
% Use FLOPS_SQRT for sqrt
% Use FLOPS_POW for .^
% Use FLOPS_EXP for exp
% Use FLOPS_LOG for log, sin, and other special functions.
%
% See FLOPS_MUL, FLOPS_SOLVE, FLOPS_INV, FLOPS_CHOL, FLOPS_DET, ...

global flopcount;
if nargin == 1
  flopcount = fl;
  if nargout == 1
    f = fl;
  end
else
  f = flopcount;
end
