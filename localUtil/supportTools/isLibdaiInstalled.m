function TF = isLibdaiInstalled()
%% Return true iff libdai is installed

% This file is from pmtk3.googlecode.com

TF = exist('dai', 'file') == 3; 
end
