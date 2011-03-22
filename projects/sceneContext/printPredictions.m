
function printPredictions(truePresence, probPresence, objectnames, methodNames, filenames, cutoffs, frames)
% print predicted objects, along with truth
% Same as visPredictions except we don't use images
% We plot labels using the EER cutoff
% truePresence(n,c), probPresence(n,c,m), objectNames{c}, methodNames{m}

for frame=frames(:)'
  
  truePresent = find(truePresence(frame,:));
  trueObjects = sprintf('%s,', objectnames{truePresent}); %#ok
  fprintf('\ntest %d\n%s\n', frame, trueObjects);
  

  for m=1:numel(methodNames)
    pp = colvec(squeeze(probPresence(frame,:,m)));
    %thresh = 0.1*cutoffs(:, m);
    thresh = cutoffs(:, m);

    %predPresent = find(pp > thresh);
    predPresent = topAboveThresh(pp, 10,  thresh);
   
    %predObjectsStr = sprintf('%s,', objectnames{predPresent});
    predObjectsStr = '';
    for i=1:numel(predPresent)
     j = predPresent(i);
     if truePresence(frame, j)
       predObjectsStr = sprintf('%s,%s', predObjectsStr, objectnames{j});
     else
       predObjectsStr = sprintf('%s,%s*', predObjectsStr, objectnames{j});
     end
     precision = sum(truePresence(frame, predPresent)) / numel(predPresent);
     recall = sum(truePresence(frame, predPresent)) / sum(truePresence(frame, :));
    end
    fprintf('%s (P=%3.2f, R=%3.2f)\n%s\n', methodNames{m}, precision, recall, predObjectsStr);
  end % for m
  
end % for frame


end