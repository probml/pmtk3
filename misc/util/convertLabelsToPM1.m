function y = convertLabelsToPM1(y)
% Ensure that y(i) is in{-1,+1}
y = canonizeLabels(y); % 1,2
y = y - 1; % 0,1
y = 2*y-1; % -1,1
end