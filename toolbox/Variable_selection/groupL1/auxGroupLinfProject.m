function w = groupLinfProject(w,p,groupStart,groupPtr)

alpha = w(p+1:end);
w = w(1:p);

for i = 1:length(groupStart)-1
    groupInd = groupPtr(groupStart(i):groupStart(i+1)-1);
    [w(groupInd) alpha(i)] = projectAuxSort(w(groupInd),alpha(i));
end
w = [w;alpha];

end

%% Function to solve the projection for a single group
function [w,alpha] = projectAuxSort(w,alpha)
if ~all(abs(w) <= alpha)
    sorted = [sort(abs(w),'descend');0];
    s = 0;
    for k = 1:length(sorted)

        % Compute Projection with k largest elements
        s = s + sorted(k);
        projPoint = (s+alpha)/(k+1);
       
        if projPoint > 0 && projPoint > sorted(k+1)
            w(abs(w) >= sorted(k)) = sign(w(abs(w) >= sorted(k)))*projPoint;
            alpha = projPoint;
            break;
        end

        if k == length(sorted)
            % alpha is too negative, optimal answer is 0
            w = zeros(size(w));
            alpha = 0;
        end
    end
end
end