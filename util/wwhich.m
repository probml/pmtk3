function out=wwhich(s1,s2)

% WWHICH Locate m-files using wildcards
%    Works exactly as WHICH, but you can
%    use wild cards.
%    
%    out is a cell whenever 2 or more
%    matches are found or if the flag
%    -all was used
%
%    Note: a function may be shawdowed,
%          use the flag -all to locate them
%
%    See WHICH for more info 

%#author Lucio Andrade
%#url http://www.mathworks.com/matlabcentral/files/1266/wwhich.m

if length(strmatch(strvcat('PCWIN'),computer))
   pathseparator=';';
elseif length(strmatch(strvcat('SUN4','SOL2','LNX86'),computer))
   pathseparator=':';
else
   warning('I''m not sure of the path separator for this machine.')
   pathseparator=':';
   disp('I''ll use '':'' as a path separator') 
end

if nargin<1
  error('Not enough input arguments.')
end

p=path;
out=cell(0);

h=[0 find(p==pathseparator) length(p)+1]; 
for i=length(h):-1:2
  direc= p(h(i-1)+1:h(i)-1);
  a=dir([direc '/' s1 '.m']);
  for j=1:length(a)
    if nargin>1
      outtmp=which(a(j).name,s2);
      if iscell(outtmp)
         out=[out;outtmp];
      else
         out=[out;{outtmp}];
      end
    else
      outtmp=which(a(j).name);
      out=[out;{outtmp}];
    end
   end
end

%take out repetitions
todel=[];
for i=1:length(out)
    for j=i+1:length(out)
        if strcmp(out{i},out{j}) todel=[todel j]; end
     end
end
out(unique(todel))=[];

%change to string when needed
if (nargin==1) & (length(out)==1)
 out=out{1};
end

if nargout==0
  if iscell(out)
    for i=1:length(out)
      disp(out{i})
    end
  else  
    disp(out)
  end
    clear out
end


