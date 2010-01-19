function restoreSeed()

global RNDN_STATE  RND_STATE
randn('state',RNDN_STATE);
rand('state',RND_STATE);