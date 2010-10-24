function  indices = partitionData(data, pc)
% Partition a vector of data into sets of different sizes
% function  indices = partitionData(data, pc)
%
% Example:
% indices =partitionData(1:105,[0.3,0.2,0.5])
% a= 1:31, b=32:52, c=53:105 (last bin gets all the left over)

% This file is from pmtk3.googlecode.com



Npartitions = length(pc);
perm = data;
Ndata = length(data);
ndx = 1;
for i=1:Npartitions
    Nbin(i) = fix(Ndata*pc(i));
    low(i) = ndx;
    if i==Npartitions
        high(i) = Ndata;
    else
        high(i) = low(i)+Nbin(i)-1;
    end
    indices{i} = perm(low(i):high(i));
    ndx = ndx+Nbin(i);
end


end
