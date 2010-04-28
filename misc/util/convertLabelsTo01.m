function y = convertLabelsTo01(y)
% Ensure that y(i) in {0,1}
y = canonizeLabels(y); % 1,2
y = y - 1; % 0,1
end