function h = htmlTagKey(tableAlign)
%% Return the html text for the demo/synopsis tag legend table

% This file is from pmtk3.googlecode.com

if nargin == 0, tableAlign = 'right'; end
tableData = ...
{
'S' , 'stats toolbox needed'          , 'I' , 'interactive (user input required)'
'B' , 'bioinformatics toolbox needed' , 'M' , 'matlab  needed (will not work in octave)'
'O' , 'optimization toolbox needed'   , 'W' , 'windows needed (will not work in linux)'
'X' , 'currently broken'              , '*' , 'slow (two stars indicates very slow)'
};
h = htmlTable('data'       , tableData , ...
              'dosave'     , false     , ...
              'doshow'     , false     , ...
              'dataAlign'  , 'left'    , ...
              'tableAlign' , tableAlign  ...
              );
end
