function [b] = alphaUsedInLoss(gradFunc)
% Function returns true if the named gradFunc needs the smoothing
%   parameter 'alpha' as a parameter

b = 0;
if strcmp(func2str(gradFunc),'LaplaceLoss') || ...
        strcmp(func2str(gradFunc),'SVMLoss') || ...
        strcmp(func2str(gradFunc),'SVMRLoss') || ...
		strcmp(func2str(gradFunc),'SVMMultiLoss')
    b = 1;
end