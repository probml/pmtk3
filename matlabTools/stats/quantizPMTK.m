function [qidx, q, d] = quantizPMTK (x, table, codes)
% [qidx, q] = quantiz(x, tables, codevalues)
% Quantize a 1d signal
% table is a vector of K-1 thresholds
% codes is a vector of K valeus (default 1:K)
% See here for more info:
% http://www.mathworks.com/help/toolbox/comm/ug/fp6386.html

% Source:
% http://lasp.colorado.edu/cism/CISM_DX/code/CISM_DX-0.50/required_packages
% /octave-forge/main/comm/quantiz.m

qidx = length(table) - lookup(flipud(table(:)), x(:));
K = numel(table)+1; 
if nargin < 3, codes = 1:K; end
q = codes(qidx + 1);
d = sum( (x(:) - q(:) .^ 2)) / length(x); % distortion
end

%{
## Copyright (C) 2001 Paul Kienzle
##
## This program is free software; you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation; either version 2 of the License, or
## (at your option) any later version.
##
## This program is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with this program; if not, write to the Free Software
## Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

## -*- texinfo -*-
## @deftypefn {Function File} {@var{qidx} = } quantiz (@var{x}, @var{table})
## @deftypefnx {Function File} {[@var{qidx}, @var{q}] = } quantiz (@var{x}, @var{table}, @var{codes})
## @deftypefnx {Function File} {[ @var{qidx}, @var{q}, @var{d}] = } quantiz (@var{...})
##
## Quantization of an arbitrary signal relative to a paritioning.
##
## @table @code
## @item qidx = quantiz(x, table)
##   Determine position of x in strictly monotonic table.  The first
##   interval, using index 0, corresponds to x <= table(1).
##   Subsequent intervals are table(i-1) < x <= table(i).
##
## @item [qidx, q] = quantiz(x, table, codes)
##   Associate each interval of the table with a code.  Use codes(1) 
##   for x <= table(1) and codes(n+1) for table(n) < x <= table(n+1).
##
## @item [qidx, q, d] = quantiz(...)
##   Compute distortion as mean squared distance of x from the
##   corresponding quantization values.
## @end table
## @end deftypefn
%}