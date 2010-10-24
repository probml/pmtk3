function  methodReport(varargin)
% Generate a report showing which classes implement and inherit which methods.
% Does not inlcude class constructors. By default, it only shows
% classes that are either abstract or contribute a new method. 

% This file is from pmtk3.googlecode.com


%
% LEGEND
% 'A'   for Abstract    (has only the abstract definition, either local or inherited)
% 'C'   for Concrete    (has access to a concrete implementation)
% 'L'   for Local       (local, possibly abstract definition)
% 'I'   for external    (no local definition, inherited from a super class)
% 'N'   for new         (local definition new to this branch of the tree
% '*'   not finished    (implemented, but not yet finished)
% '--'  does not have access to the method at all
% PMTKneedsMatlab 2008


    ABSTRACT     = 'A';
    CONCRETE     = 'C';
    OVERRIDES    = 'O';
    EXTERNAL     = 'I';
    NEW          = 'N';
    NYF          = '*';
    NUL          = '';
    
     legend =  { ABSTRACT   , 'Abstract' ;
                 CONCRETE   , 'Concrete';
                 NEW        , 'Introduces';
                 OVERRIDES  , 'Overrides';
                 EXTERNAL   , 'Inherits';
                 NYF        , 'Unfinished';
               };
    

    [source,excludeClasses,dosave,filename,diffOnly,includeLegend]= process_options(varargin,'source',PMTKroot(),'excludeClasses',{},'dosave',false,'filename','','diffOnly',true,'includeLegend',true);
    if dosave, includeLegend = false; end
    classes = setdiff(classesBFS(),excludeClasses);
    classMethods = cellfuncell(@(c)methodsNoCons(c),classes);
    methodNames = unique(vertcat(classMethods{:}));
    methodLookup = enumerate(methodNames);
    classLookup  = enumerate(classes);
    
    table = repmat({NUL},numel(methodNames),numel(classes)); 
    for c=1:numel(classes)
        meths = methodsNoCons(classes{c});
        for m=1:numel(meths)
            minfo = methodInfo(classes{c},meths{m});
            if minfo.isAbstract, first = ABSTRACT; else first = CONCRETE;end
            if minfo.isNewToBranch
                second = NEW;
            elseif minfo.isLocal
                second = OVERRIDES;
            else
                second = EXTERNAL;
            end
            if minfo.isUnfinished
                third = NYF;
            else
                third = '&nbsp;';
            end
            table(methodLookup.(meths{m}),classLookup.(classes{c})) = {[first,second,third]};
        end
    end
    
    newTable = cellfun(@(c)ismember(NEW,c),table);
    
    
    if diffOnly
        remove = ~any(newTable,1);
        classes(remove)  = [];
        table(:,remove) = [];
        newTable = cellfun(@(c)ismember(NEW,c),table);
    end
    notNewTable = ~newTable &  ~findString(NUL,table);
    
    dataColors = repmat({'red'},size(table));
    dataColors(newTable) = {'lightgreen'};
    dataColors(cellfun(@(c)ismember(OVERRIDES,c),table)) = {'blue'};
    dataColors(cellfun(@(c)ismember(EXTERNAL,c),table)) = {'yellow'};
    perm = sortidx(1000*sum(newTable,1) + sum(notNewTable),'descend');
    classes = classes(perm);
    table = table(:,perm);
    dataColors = dataColors(:,perm);
    
    mperm = sortidx(sum(findString(NUL,table),2));
    methodNames = methodNames(mperm);
    table = table(mperm,:);
    dataColors = dataColors(mperm,:);
    
    classNames = shortenNames(classes);
           
     legColors = repmat({'white'},size(legend));
     legColors(3,:) = {'lightgreen'}; 
     legColors(4,:) = {'blue'}; 
     legColors(5,:) = {'yellow'}; 
          
     if includeLegend
        legendTable = htmlTable('data',legend,'title','Legend','colNames',{'Code','Description'},'doshow',false,'dataAlign','left','dataColors',legColors,'borderColor','black');
        caption = [repmat('<br>',1,8),legendTable];
     else
         caption = '';
     end
               
           
    
    htmlTable('data'               , table                            ,...
              'rowNames'           , methodNames                      ,...
              'colNames'           , classNames                       ,...
              'title'              , 'Methods Report'                 ,...
              'vertCols'           , false                            ,...
              'titleFontSize'      , 4                                ,...
              'dataFontSize'       , 4                                ,...
              'rowNameFontSize'    , 3                                ,...
              'cellPad'            , 1                                ,...
              'colNameFontSize'    , 3                                ,...
              'dosave'             , dosave                           ,...
              'dataColors'         , dataColors                       ,...
              'caption'            , caption                          ,...
              'captionLoc'         ,'right'                           ,...
              'filename'           , filename                         );
          
          
          
          
          
          
    function names = shortenNames(names)
        
         maxlen = 0;
         splitNames = cell(numel(names),1);
         for n=1:numel(names)
                
             splitNames{n} = splitString(names{n},8,10,true,true);
             maxlen = max(maxlen,max(cellfun(@(c)length(c),splitNames{n})));
             
         end
         
         for i=1:numel(splitNames)
            [len,idx] =  max(cellfun(@(c)length(c),splitNames{i}));
            nrep = ceil((maxlen - len + 3)/2);
            splitNames{i}{idx} = [repmat('&nbsp;',1,nrep),splitNames{i}{idx},repmat('&nbsp;',1,nrep)];
         end
         names = cellfuncell(@(c)catString(c,' <br> '),splitNames);
    end
end
