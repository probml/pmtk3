function S = structure(varargin)
% Create a struct directly from variables, without having to provide names
% The current names of the variables are used as the structure fields.
%
% *** does not support anonymous variables as in structure(25, 2+3), etc ***
%
%% Example 
%
% mu = zeros(1, 10);
% Sigma = randpd(10);
% pi = normalize(ones(1, 10)); 
% model = structure(mu, Sigma, pi); 
% model
% model = 
%        mu: [0 0 0 0 0 0 0 0 0 0]
%     Sigma: [10x10 double]
%        pi: [1x10 double]
%%

% This file is from pmtk3.googlecode.com


for i=1:nargin
    S.(inputname(i)) = varargin{i};
end


end

