function h = contourShade(X, Y, Z, C, varargin)
% Just like countourf but with a better interface. 

% This file is from pmtk3.googlecode.com

    
   [junk1, h, junk2] = contourf(X, Y, Z, C); 
   if nargin > 4
     set(h, varargin{:}); 
   end
    
end
