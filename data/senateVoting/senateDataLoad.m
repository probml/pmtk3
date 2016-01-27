function [records,party,senators,bills,nmissedVotes] = senateDataLoad()
% Senate Voting data from 109th Congress 2004-2006    
% 
% records 
%       542-by-100 matrix of -1, 0, +1 representing the voting records
%       of 100 Senators on 542 bills. 
%
% party
%       the party to which each senator is affiliated, either 'd','r',
%       or 'i' for independent. You can convert these to numeric labels with 
%       [labels,map] = canonizeLabels(party);
%
% senators 
%       the list of senators
%
% bills  
%       the list of bills
%
% nmissedVotes 
%       the number of missed votes for each senator
%
   S = importdata('senate_voting_data.txt');
   nmissedVotes = S.data(:,1);
   records = S.data(:,2:end);
   bills = S.textdata(2:end,1);
   senators = S.textdata(1,3:end);
   senators = cellfuncell(@(c)strtrim(c(1:end-5)),senators);
   senators{37} = 'Jefferson B. ''Jeff'' Sessions'; % remove the jr.
   senators{41} = 'John D. ''Jay'' Rockefeller';    % remove the IV
   senators{52} = 'Joseph R. Biden';                % remove the jr.
   
   %% Find out party affiliations
   load senatorAffil  
   % data from http://en.wikipedia.org/wiki/109th_United_States_Congress
   % Copied table to clipboard, pasted into notepad to remove
   % formatting, loaded into Matlab using raw = getText and removed junk with
   % senatorAffil = raw(cellfun(@(c)ismember('(',c),raw)).
   
   senatorAffil = cellfuncell(@(c)tokenize(c,'()'),senatorAffil);
   wikiSenators  = cellfuncell(@(c)strtrim(lower(c{1})),senatorAffil);
   affil     = cellfuncell(@(c)strtrim(lower(c{2})),senatorAffil);
  
   senatorLastNames = cellfuncell(@(C)C{end},cellfuncell(@(c)tokenize(c),lower(senators)));
    % numel(unique(senatorLastNames))  
    % there are two senators with last name 'nelson' - both democrats
    %'E. Benjamin 'Ben' Nelson' #5 - (D)
    %'Bill Nelson' #22 - (D)
   
   wikiSenatorLastNames = cellfuncell(@(C)C{end},cellfuncell(@(c)tokenize(c),lower(wikiSenators)));
   
   party = cell(numel(senators),1);
   for i=1:numel(senators)
       for w=1:numel(wikiSenators)
          if strcmp(senatorLastNames{i},wikiSenatorLastNames{w}); 
              party{i} = affil{w}(1);
              break;
          end
       end
   end
   
   assert(~any((cellfun(@(c)isempty(c),party)))); % assert that we now know the party for each senator
   
   
   
   
   
   
   
   
   
end