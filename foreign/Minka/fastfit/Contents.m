% Fastfit Toolbox.  Efficient maximum-likelihood estimation using generalized
% Newton iterations.
% Version 1.2  19-May-04
% By Thomas P. Minka
%
% Dirichlet
%   dirichlet_sample     - Sample from Dirichlet distribution.
%   dirichlet_logprob    - Evaluate a Dirichlet distribution.
%   dirichlet_fit        - Maximum-likelihood Dirichlet distribution.
%   dirichlet_fit_simple - Maximum-likelihood Dirichlet distribution.
%   dirichlet_fit_newton - Maximum-likelihood Dirichlet distribution.
%   dirichlet_fit_m      - Maximum-likelihood Dirichlet mean.
%   dirichlet_fit_s      - Maximum-likelihood Dirichlet precision.
%
% Polya, a.k.a. Dirichlet-multinomial
%   polya_sample   - Sample from Dirichlet-multinomial (Polya) distribution.
%   polya_logprob  - Evaluate a Dirichlet-multinomial (Polya) distribution.
%   polya_fit      - Maximum-likelihood Polya distribution.
%   polya_fit_ms   - Maximum-likelihood Polya distribution.
%   polya_fit_simple  - Maximum-likelihood Polya distribution.
%   polya_fit_s    - Maximum-likelihood Polya precision.
%   polya_fit_m    - Maximum-likelihood Polya mean.
%
% Other
%   gamma_fit      - Maximum-likelihood Gamma distribution.
%   negbin_fit     - Maximum-likelihood Negative Binomial.
%   randnegbin     - Sample from Negative Binomial.
%   inv_digamma    - Inverse of the digamma function.
%
% test_dirichlet_fit,...   Test scripts for above routines.
