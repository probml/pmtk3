function [G, names] = parseAlarmData()
% data from http://www.cs.huji.ac.il/site/labs/compbio/Repository/Datasets/alarm/alarm.net


T = removeEmpty(getText('alarm.net'));

names = {}; 
for i=1:numel(T)
   line = T{i};
   if startswith(line, '(var')
      toks = tokenize(line); 
      V = toks{2};
      
      names = insertEnd(V(2:end), names); 
   end
end
names = names'; 

map = enumerate(names); 
G = zeros(numel(names)); 

for i=1:numel(T)
   line = T{i};
   if startswith(line, '(parents')
      toks = tokenize(line, '''');
      child = deblank(toks{2});
      
      rawParents = deblank(toks{3}); 
      rawParents(1) = [];
      rawParents(end) = []; 
      parents = tokenize(rawParents, ' '); 
      for j = 1:numel(parents)
         P = parents{j};
         if (length(P) > 0)
            G(map.(P), map.(child)) = 1; 
         end
      end
      
      
      
   end
end

end


