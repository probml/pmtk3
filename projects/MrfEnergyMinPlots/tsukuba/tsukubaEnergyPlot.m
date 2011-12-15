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
lines{1} = {'icm.txt',         'ICM'      ,   '*', 'c',             'none',          [0.2   670.68]};
lines{2} = {'expansion.txt',   'Expansion',   '^', 'r',             'r',             [0.2,  102]};
lines{3} = {'swap.txt',        'Swap',        'd', [0.0, 0.0, 0.5], [0.0, 0.0, 0.5], [3,    107]};
lines{4} = {'trw-s.txt',       'TRW-S',       'o', [0.5, 0.0, 0.0], [0.5, 0.0, 0.0], [0.4,  111.5]};
lines{5} = {'lower_bound.txt', 'Lower bound', '+', [0.0, 0.5, 0.5], [0.0, 0.5, 0.5], [1.7,   97]};
lines{6} = {'bp-s.txt',        'BP-S',        'o', 'b',             'none',          [0.25, 122]};
lines{7} = {'bp-m.txt',        'BP-M',        's', [0.0, 0.5, 0.0], [0.0, 0.5, 0.0], [50,   113]};


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
xlim([0, 1000]);
set(gca, 'XScale', 'log');
set(gca, 'XTick',       [0.1,    1,    10,    100,    1000]);
set(gca, 'XTickLabel', {'0.1s', '1s', '10s', '100s', '1000s'});
ylim([95, 125]);
set(gca, 'YTick',       [95,    100,    105,    110,    115,    120,    125]);
set(gca, 'YTickLabel', {'95%', '100%', '105%', '110%', '115%', '120%', '125%'});

set(gca, 'YGrid', 'on');
set(gca, 'XGrid', 'off');
set(gca, 'FontSize', 12, 'FontWeight', 'bold');

hold off;