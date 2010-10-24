function y = convertLabelsTo01(y)
% Ensure that y(i) is in {0,1}

% This file is from pmtk3.googlecode.com

y = canonizeLabels(y); % 1,2
y = y - 1; % 0,1
end
