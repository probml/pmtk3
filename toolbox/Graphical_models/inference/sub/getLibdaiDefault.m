function opts = getLibdaiDefault(alias)
%% Get the libdai default for the given alias
% These are parsed from aliases.conf by libdaiParseAliasesConf.m

load('libdaiDefaults');
opts = S.(upper(alias)); 

end