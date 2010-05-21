function w = groupL2Proj(w,p,groupStart,groupPtr)

alpha = w(p+1:end);
w = w(1:p);

for i = 1:length(groupStart)-1
    groupInd = groupPtr(groupStart(i):groupStart(i+1)-1);
    [w(groupInd) alpha(i)] = projectAux(w(groupInd),alpha(i));
end
w = [w;alpha];

end

%% Function to solve the projection for a single group
function [w,alpha] = projectAux(w,alpha)
p = length(w);
nw = norm(w);
    if nw > alpha
       avg = (nw+alpha)/2;
       if avg < 0
           w(:) = 0;
           alpha = 0;
       else
           w = w*avg/nw;
           alpha = avg;
       end 
    end
end
