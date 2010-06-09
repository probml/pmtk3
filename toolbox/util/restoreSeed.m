function restoreSeed()
%% Restore the random seed altered by setSeed
global RNDN_STATE  RND_STATE
randn('state',RNDN_STATE);
rand('state',RND_STATE);

end