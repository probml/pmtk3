function [logZ, nodeBels, clqBels, cliqueLookup] = libdaiBelProp(tfacs)
%% Bare bones interface to libdai's belief propagation algorithm 
% 
%% Input
%
% tfacs     - a cell array of tabular factors
%
%% Outputs
%
% logZ     - log of the partition sum
%
% nodeBels - all single marginals (node beliefs)
%
% clqBels  - all of the clique beliefs
%
% cliqueLookup - an nvars-by-ncliques lookup table
%%
[logZ, nodeBels, clqBels, cliqueLookup] = libdaiInfer(tfacs, 'BP', '[updates=SEQMAX,tol=1e-9,maxiter=10000,logdomain=0]');
end