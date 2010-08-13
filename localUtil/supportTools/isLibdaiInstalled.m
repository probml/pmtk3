function TF = isLibdaiInstalled()
%% Return true iff libdai is installed
TF = exist('dai', 'file') == 3; 
end