function text = mlcompCompiler(fitFn, predictFn, outputDirectory)

if endswith(fitFn, '.m')
    fitFn = fitFn(1:end-2);
end
if endswith(predictFn, '.m')
    predictFn = predictFn(1:end-2);
end


fitText     = getText(fitFn);
predictText = getText(predictFn);

filter = @(s)endswith(s, '.m');

fitDependencies     = filterCell(depfunFast(fitFn, true), filter);
predictDependencies = filterCell(depfunFast(predictFn, true), filter);




text = {
          '#!/usr/bin/octave -qf'
          'args = argv();'
          ''
          '%% FIT FUNCTION'
          ''
       };
text = [  text
          fitText
          ''
          '%% PREDICT FUNCTION'
          ''
          predictText
          ''
          '%% FIT DEPENDENCIES'
          ''
        ];

for i=1:numel(fitDependencies)
   text = [text; getText(fitDependencies{i}); ''];
end
   
text = [text; '%% PREDICT DEPENDENCES'];
for i=1:numel(predictDependencies)
   text = [text; getText(predictDependencies{i}); ''];
end

text = [text
        '%% GETTEXT FUNCTION'
        ''
        getText('getText.m');
        ''
        ];

text = [text
        '%% DATA READER'
        ''
        getText('mlcompReadData.m');
        ''
       ];

text = [text
        '%% START SCRIPT'
        ''
        'switch(args{1})'
        '    case ''learn'''
        '        [X, y] = mlcompReadData(args{2});'
        sprintf('        model = %s(X, y);', fitFn);
        '        save(''model'', ''model'');'     
        '    case ''predict'''
        '        S = load(''model'');'
        '        model = S.model;'
        '        [X, y] = mlcompReadData(args{2});'
        sprintf('        yhat = %s(model, X);', predictFn);
        '        fid = fopen(args{3}, ''w'');'
        '        for i=1:numel(yhat)'
        '            fprintf(fid, ''%f\n'', yhat(i));'
        '        end'
        '        fclose(fid);'        
        ''
        'end'
        ];


writeText(text, fullfile(outputDirectory, 'run'));            



end