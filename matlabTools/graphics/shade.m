
% This file is from pmtk3.googlecode.com

function shade(func,lower,left,right,color,resolution)
    if(nargin < 6)
        resolution = 0.0001;
    end
    hold on;
    res = left:resolution:right;
    x = repmat(res,2,1);
    y = [lower*ones(1,length(res)) ; rowvec(func(res))];
    line(x,y,'Color',color);

end
