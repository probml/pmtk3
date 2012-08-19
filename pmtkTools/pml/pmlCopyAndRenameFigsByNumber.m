function pmlCopyAndRenameFigsByNumber
%% Copy every pdf figure in the book naming it e.g. fig11.8b.pdf
%
% Requirements:
%
% (1) The correct path to the book must be in config-local.txt
% (2) All chapters must be included directly in pml.tex, (just
%     copy pmlcore.tex right into pml.tex)
% (3) The figure index must be made - add /makeindex{figures}
% (4) Call makeIndex figures from the command line
% (5) The book must be correctly compiled

sourceDir = '/Users/matt/Documents/MLbook/Figures/pdfFigures';
destDir = '/Users/matt/Desktop/figs/';
prefix = 'fig';
suffix = '.pdf';

%%
subIdentifiers = {'a', 'b', 'c', 'd', 'e', 'f', 'g', 'h', 'i', 'j'};

%%


F = pmlFigureInfo;
F = [F{:}];

for i=1:numel(F)
   S = F(i);
   newBaseName = [prefix, S.figNumTxt];
   for j=1:numel(S.fnames)
      originalName = S.fnames{j};
      originalPath = fullfile(sourceDir, [originalName, suffix]); 
      
      if (numel(S.fnames) > 1)
        newName = [newBaseName, subIdentifiers{j}, suffix];
      else
        newName = [newBaseName, suffix];  
      end
      newPath = fullfile(destDir, newName); 
      [status, message] = copyfile(originalPath, newPath);
      if (~status)
         printf(message);  
      end
          
        
   end
end



end