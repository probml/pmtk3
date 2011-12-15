%% ------------------------------------------------------------------------
% configuration
%    every line contains three fields:
%       'filename'
%       'legend text'
%       'Marker' 
%       'Color'
%       'MarkerFaceColor'
%       'TextPosition':    [x, y]
% -------------------------------------------------------------------------
lines{1} = {'icm.txt',         'ICM'      ,   '*', 'c',             'none',          [7,    1400]};
lines{2} = {'expansion.txt',   'Expansion',   '^', 'r',             'r',             [8,    10000]};
lines{3} = {'swap.txt',        'Swap',        'd', [0.0, 0.0, 0.5], [0.0, 0.0, 0.5], [10,   500]};
lines{4} = {'trw-s.txt',       'TRW-S',       'o', [0.5, 0.0, 0.0], [0.5, 0.0, 0.0], [5,    6200]};
lines{5} = {'lower_bound.txt', 'Lower bound', '+', [0.0, 0.5, 0.5], [0.0, 0.5, 0.5], [1,    250]};
lines{6} = {'bp-s.txt',        'BP-S',        'o', 'b',             'none',          [17,   2200]};
lines{7} = {'bp-m.txt',        'BP-M',        's', [0.0, 0.5, 0.0], [0.0, 0.5, 0.0], [50,   1000]};


%% ------------------------------------------------------------------------
% plotline style
% -------------------------------------------------------------------------
figure; clf; hold on;
grid
position = get(gcf, 'Position');
position(2) = 100;
position(3:4) = [700, 600];
set(gcf, 'Position', position);

for k = 1 : length(lines)
    [x, y] = textread(lines{k}{1}, '%f %f');
    plot(x, y, ...
        'LineStyle', '-', 'LineWidth', 2, 'Color', lines{k}{4}, ...
        'Marker', lines{k}{3}, 'MarkerSize', 10, 'MarkerFaceColor', lines{k}{5});
    text_pos = lines{k}{6};
    text(text_pos(1), text_pos(2), lines{k}{2}, 'FontSize', 16, 'FontWeight', 'bold', 'Color', lines{k}{4});
end
xlim([1, 1000]);
set(gca, 'XScale', 'log');
set(gca, 'XTick',       [1,    10,    100,    1000]);
set(gca, 'XTickLabel', {'1s', '10s', '100s', '1000s'});
ylim([0, 8000]);
set(gca, 'YTick',       [0,    1000,    2000,    3000,    4000,    5000,    6000,    7000,    8000]);
set(gca, 'YTickLabel', {'0%', '1000%', '2000%', '3000%', '4000%', '5000%', '6000%', '7000%', '8000%'});

set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'off');
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

hold off;