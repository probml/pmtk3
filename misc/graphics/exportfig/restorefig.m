function restorefig(h,old)
%RESTOREFIG  Restore a figure's properties
%   RESTOREFIG(H,OLD) restores the properties of H specified in
%   OLD. The state-difference structure OLD is the output of the
%   function APPLYTOFIG. Deleting object handles after the call to
%   APPLYFIG might cause undesired behavior.
%
%   See also EXPORTFIG, PREVIEWFIG, APPLYTOFIG.

%  Copyright 2000 Ben Hinkle
%  Email bug reports and comments to bhinkle@mathworks.com

%PMTKauthor Ben Hinkle
%PMTKurl http://www.mathworks.com/matlabcentral/fileexchange/727

for n=1:length(old.objs)
  try
    if ~iscell(old.values{n}) & iscell(old.prop{n})
      old.values{n} = {old.values{n}};
    end
    set(old.objs{n}, old.prop{n}, old.values{n});
  end
end

end