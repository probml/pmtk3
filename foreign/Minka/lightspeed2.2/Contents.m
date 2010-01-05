% Lightspeed Toolbox.  
% Efficient operations for Matlab programming.
% Version 2.2   17-Dec-2007
% By Tom Minka
% (c) Microsoft Corporation. All rights reserved. 
%
% Matrix algebra
%   repmat           - Fast replacement for matlab's repmat.
%   xrepmat          - Matlab's original repmat.
%   row_sum          - Sum for each row.  Faster than 'sum'.
%   scale_rows       - Scale each row of a matrix.
%   scale_cols       - Scale each column of a matrix.
%   solve_triu       - Left division by upper triangular matrix.
%   solve_tril       - Left division by lower triangular matrix.
%   sqdist           - Squared Euclidean and Mahalanobis distance.
%   isposdef         - Check for positive-definiteness.
%   logdet           - log(determinant) for positive definite matrix.
%   cholproj         - Projected Cholesky factorization.
%   inv_posdef       - Invert positive definite matrix.
%
% Statistics
%   normpdf          - Multivariate normal density.
%   normpdfln        - Log of multivariate normal density.
%   normcdf          - Normal cumulative distribution.
%   normcdfln        - Log of normal cumulative distribution.
%   normcdflogit     - Logit of normal cumulative distribution.
%   wishpdf          - Wishart probability density function.
%   wishpdfln        - Log of Wishart probability density function.
%   sample           - Sample from categorical distribution.
%   sample_vector    - Sample from multiple categorical distributions.
%   sample_hist      - Sample from multinomial distribution.
%   randbinom        - Sample from binomial distribution.
%   randnorm         - Sample from multivariate normal.
%   randgamma        - Sample from Gamma distribution.
%   randbeta         - Sample from Beta distribution.
%   randwishart      - Sample from Wishart distribution.
%   randomseed       - Get or set the random seed.
%   int_hist         - Histogram of integer values.
%
% Utility
%   logsumexp        - Sum in the log domain.
%   logmulexp        - Matrix multiply in the log domain.
%   ndgridmat        - Matrix of grid points.
%   ind2subv         - Subscript vector from linear index.
%   subv2ind         - Linear index from subscript vector.
%   gammaln          - Fast replacement for matlab's gammaln.
%   digamma          - Derivative of gammaln.
%   trigamma         - Derivative of digamma.
%   ndsum            - Sum over multiple dimensions.
%   ndmax            - Maximum over multiple dimensions.
%   ndlogsumexp      - Sum over multiple dimensions in the log domain.
%   maxdiff          - Maximum difference between structs or arrays.
%   sameobject       - Test if two variables correspond to the same object.
%   find_sameobject  - Find an object in a cell array.
%   toJava           - Convert to Java representation.
%   fromJava         - Convert from Java to Matlab.
%   glob             - Filename expansion via wildcards.
%   globstrings      - String matching via wildcards.
%
% Argument lists
%   argfilter        - Remove unwanted arguments from a key/value list.
%   makestruct       - Cell-friendly alternative to STRUCT.
%   setfields        - Set multiple fields of a structure.
%   struct2arglist   - Convert structure to cell array of fields/values.
%
% Mutation
%   mutable          - Convert to a mutable object.
%   immutable        - Convert to an ordinary (immutable) object.
%
% Set operations
%   ismember_sorted  - True for member of sorted set.
%   match            - Location of matches in a set.
%   match_sorted     - Location of matches in a sorted set.
%   setdiff_sorted   - Set difference between sorted sets.
%   intersect_sorted - Set intersection between sorted sets.
%   union_sorted     - Set union of sorted sets.
%   union_sorted_rows - Set union of sorted sets of row vectors.
%   duplicated       - Find duplicated rows in a matrix.
%
% Readability
%   rows             - Number of rows.
%   cols             - Number of columns.
%   col_sum          - Sum for each column.
%   setdiag          - Modify the diagonals of a matrix.
%   finddiag         - Index of elements on diagonals.
%   argmax           - Index of maximum element.
%   argmin           - Index of minimum element.
%
% Flop counting
%   flops            - Read/write flop counter.
%   addflops         - Add to flop counter.
%   flops_chol       - Flops for Cholesky decomposition.
%   flops_col_sum    - Flops for column sums.
%   flops_det        - Flops for matrix determinant.
%   flops_digamma    - Flops for gammaln, digamma, and trigamma.
%   flops_div        - Flops for division.
%   flops_exp        - Flops for exponential.
%   flops_inv        - Flops for matrix inversion.
%   flops_mul        - Flops for real matrix multiplication.
%   flops_normpdfln  - Flops for normpdfln.
%   flops_pow        - Flops for raising to real power.
%   flops_randnorm   - Flops for randnorm.
%   flops_row_sum    - Flops for row sums.
%   flops_sample     - Flops for sample(p,n).
%   flops_solve      - Flops for matrix left division.
%   flops_solve_tri  - Flops for triangular left division.
%   flops_spadd      - Flops for sparse matrix addition.
%   flops_spmul      - Flops for sparse matrix multiplication.
%   flops_sqrt       - Flops for square root.
%
% Stand alone programs
%   matfile          - Read/write MAT files.
%   tests/test_flops - Compare time versus flops for various math operations.
%
% Graphics utilities
%  see graphics/Contents.m
%
% Demos
%   tests/test_repmat,
%   tests/test_solve_tri, ...
