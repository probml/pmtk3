function [model, loglikHist] = ldsFit(data, nlatent, varargin)
%% Fit a linear dynamical system model via EM
% We do not estimate parameters associated with an input/ control sequence.
% We fix Q=I and R=diagonal.
% See ldsFit.pdf for details of the algorithm.
%
%% Inputs
% data         - a cell array of observation sequences; each sequence is
%                d-by-seqLength, where d is dimensionalty of y
%
% nlatent      - dimensionality of hidden states
%
%% Optional inputs
% addOffset - set to true (default) if we want to use y=Cz + b
% useMap - set to true (default) to do MAP parameter estimation
%
%% EM related inputs
% *** See emAlgo for additional EM related optional inputs ***
%
%% Outputs
%
% model         - a struct with fields
%   A, C, b, Q, R, m1, Sigma1
% loglikHist    - history of the log likelihood

% This file is from pmtk3.googlecode.com

[model, loglikHist] = ldsFitEm(data, nlatent, varargin{:});
end
