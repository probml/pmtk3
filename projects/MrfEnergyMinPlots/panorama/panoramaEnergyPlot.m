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
lines{1} = {'icm.txt',         'ICM'      ,   '*', 'c',             'none',          [11.3	525.15]};
lines{2} = {'expansion.txt',   'Expansion',   '^', 'r',             'r',             [8,    108]};
lines{3} = {'swap.txt',        'Swap',        'd', [0.0, 0.0, 0.5], [0.0, 0.0, 0.5], [4,    150]};
lines{4} = {'trw-s.txt',       'TRW-S',       'o', [0.5, 0.0, 0.0], [0.5, 0.0, 0.0], [300,  132]};
lines{5} = {'lower_bound.txt', 'Lower bound', '+', [0.0, 0.5, 0.5], [0.0, 0.5, 0.5], [105,   90]};
lines{6} = {'bp-s.txt',        'BP-S',        'o', 'b',             'none',          [7.9	1054.64]};
lines{7} = {'bp-m.txt',        'BP-M',        's', [0.0, 0.5, 0.0], [0.0, 0.5, 0.0], [800,  165]};


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
xlim([1, 10000]);
set(gca, 'XScale', 'log');
set(gca, 'XTick',       [1,    10,    100,    1000,    10000]);
set(gca, 'XTickLabel', {'1s', '10s', '100s', '1000s', '10000s'});
ylim([80, 180]);
set(gca, 'YTick',       [80,    100,    120,    140,    160,    180]);
set(gca, 'YTickLabel', {'80%', '100%', '120%', '140%', '160%', '180%'});

set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'off');
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

hold off;